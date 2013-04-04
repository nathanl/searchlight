require 'set'

module Pilfer
  class Search

    class << self
      attr_reader :search_target, :search_methods
    end

    def self.method_added(name)
      @search_methods ||= Set.new
      @search_methods << name if name.to_s.end_with?('_search')
    end

    def self.search_on(target)
      @search_target = target
    end

    def self.searches(*attribute_names)
      include_new_module "PilferAccessors" do
        attr_accessor *attribute_names
      end
    end

    def self.coerces(*attribute_names, options)
      coerce_to = options.fetch(:to) { raise ArgumentError.new "You must provide a :to option" }
      include_new_module "PilferCoercions" do
        attribute_names.each do |attribute_name|
          define_method(attribute_name) do
            coerce(super(), coerce_to)
          end
        end
      end
    end 

    attr_writer :search

    def initialize(options = {})
      options.each { |key, value| public_send("#{key}=", value) }
    end

    def search
      @search ||= self.class.search_target
    end

    private

    # So that we can allow calling `super` in submodules and the base class.
    def self.include_new_module(module_name, &content)
      include Named::Module.new(module_name, &content)
    end

    def coerce(value, coersion)
      Coercer.public_send(coersion, value)
    end

  end
end
