module Searchlight
  class Search
    extend DSL

    def self.search_target
      return @search_target if defined?(@search_target)
      return superclass.search_target if superclass.respond_to?(:search_target) && superclass != Searchlight::Search
      if self.name.end_with?('Search')
        @search_target = name.sub(/Search$/, '').split('::').inject(Kernel, &:const_get)
      else
        raise MissingSearchTarget, "No search target provided via `search_on` and Searchlight can't guess one."
      end
    rescue NameError => e
      if e.message.start_with?("uninitialized constant")
        raise MissingSearchTarget, "No search target provided; guessed target not found. Error: #{e.message}"
      end
      raise e # unknown error
    end

    def initialize(options = {})
      options.each { |key, value| public_send("#{key}=", value) } if options && options.any?
    rescue NoMethodError => e
      raise UndefinedOption.new(e.name, self.class.name)
    end

    def search
      @search ||= self.class.search_target
    end

    def results
      @results ||= run
    end

    protected

    attr_writer :search

    private

    def search_methods
      public_methods.map(&:to_s).select { |m| m.start_with?('search_') }
    end

    def run
      search_methods.each do |method|
        new_search  = run_search_method(method)
        self.search = new_search unless new_search.nil?
      end
      search
    end

    def run_search_method(method_name)
      option_value = instance_variable_get("@#{method_name.sub(/\Asearch_/, '')}")
      option_value = option_value.reject { |item| blank_value?(item) } if option_value.respond_to?(:reject)
      public_send(method_name) unless blank_value?(option_value)
    end

    # Note that false is not blank
    def blank_value?(value)
      (value.respond_to?(:empty?) && value.empty?) || value.nil? || value.to_s.strip == ''
    end

    class UndefinedOption < StandardError
      attr_accessor :message
      def initialize(option_name, search_class)
        option_name = option_name.to_s.sub(/=\Z/, '')
        self.message = "#{search_class} doesn't search '#{option_name}'."
        if option_name.start_with?('search_')
          # Gee golly, I'm so helpful!
          self.message << " Did you just mean '#{option_name.sub(/\Asearch_/, '')}'?"
        end
      end

      def to_s
        message
      end
    end

    class MissingSearchTarget < StandardError
    end

  end
end
