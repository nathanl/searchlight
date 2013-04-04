require 'set'

module Pilfer
  class Search
    extend DSL

    def self.search_target
      defined?(@search_target) ? @search_target : superclass.search_target
    end

    def self.search_methods
      defined?(@search_methods) ? @search_methods : superclass.search_methods
    end

    def self.method_added(name)
      @search_methods ||= Set.new
      search_methods << name.to_s if name.to_s.end_with?('_search')
    end

    def initialize(options = {})
      options.each { |key, value| public_send("#{key}=", value) }
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

    def coerce(value, coersion)
      Coercer.public_send(coersion, value)
    end

    def run
      self.class.search_methods.each do |method|
        self.search = public_send(method)
      end
      search
    end

  end
end
