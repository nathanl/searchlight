module Searchlight
  class Search
    extend DSL

    attr_accessor :options

    def self.search_target
      return @search_target           if defined?(@search_target)
      return superclass.search_target if superclass.respond_to?(:search_target) && superclass != Searchlight::Search
      guess_search_class!
    end

    def initialize(options = {})
      filter_and_mass_assign(options)
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

    def self.guess_search_class!
      if self.name.end_with?('Search')
        @search_target = name.sub(/Search\z/, '').split('::').inject(Kernel, &:const_get)
      else
        raise MissingSearchTarget, "No search target provided via `search_on` and Searchlight can't guess one."
      end
    rescue NameError => e
      if /uninitialized constant/.match(e.message)
        raise MissingSearchTarget, "No search target provided via `search_on` and Searchlight's guess was wrong. Error: #{e.message}"
      end
      raise e
    end

    def self.search_target=(value)
      @search_target = value
    end

    def filter_and_mass_assign(provided_options)
      self.options = provided_options.reject { |key, value| is_blank?(value) }
      begin
        options.each { |key, value| public_send("#{key}=", value) } if options && options.any?
      rescue NoMethodError => e
        raise UndefinedOption.new(e.name, self)
      end
    end

    def run
      options.each do |option_name, value|
        new_search  = public_send("search_#{option_name}") if respond_to?("search_#{option_name}")
        self.search = new_search unless new_search.nil?
      end
      search
    end

    # Note that false is not blank
    def is_blank?(value)
      (value.respond_to?(:empty?) && value.empty?) || value.nil? || value.to_s.strip == ''
    end

    MissingSearchTarget = Class.new(Searchlight::Error)

    class UndefinedOption < Searchlight::Error

      attr_accessor :message

      def initialize(option_name, search)
        option_name = option_name.to_s.sub(/=\Z/, '')
        self.message = "#{search.class.name} doesn't search '#{option_name}' or have an accessor for that property."
        if option_name.start_with?('search_')
          method_maybe_intended = option_name.sub(/\Asearch_/, '')
          # Gee golly, I'm so helpful!
          self.message << " Did you just mean '#{method_maybe_intended}'?" if search.respond_to?("#{method_maybe_intended}=")
        end
      end

      def to_s
        message
      end

    end

  end
end
