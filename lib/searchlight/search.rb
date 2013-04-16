module Searchlight
  class Search
    extend DSL

    def self.search_target
      defined?(@search_target) ? @search_target : superclass.search_target
    end

    def initialize(options = {})
      options.each { |key, value| public_send("#{key}=", value) } if options && options.any?
    rescue NoMethodError => e
      option_given = e.name.to_s.sub(/=\Z/, '')
      message = "No known option called '#{option_given}'."
      if e.name.to_s.start_with?('search_')
        option_guess = option_given.sub(/\Asearch_/, '')
        message << " Did you just mean '#{option_guess}'?"
      end
      raise UndefinedOption.new(message)
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

    UndefinedOption = Class.new(Searchlight::Error)
  end
end
