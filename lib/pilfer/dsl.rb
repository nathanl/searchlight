module Pilfer
  module DSL

    def search_on(target)
      @search_target = target
    end

    def searches(*attribute_names)
      include_new_module "PilferAccessors" do
        attr_accessor *attribute_names
      end
    end

    def coerces(*attribute_names, options)
      coerce_to = options.fetch(:to) { raise ArgumentError.new "You must provide a :to option" }

      include_new_module "PilferCoercions" do
        attribute_names.each do |attribute_name|
          define_method(attribute_name) do
            coerce(super(), coerce_to)
          end
        end
      end
    end

    private

    # So that we can allow calling `super` in submodules and the base class.
    def include_new_module(module_name, &content)
      include Named::Module.new(module_name, &content)
    end

  end
end
