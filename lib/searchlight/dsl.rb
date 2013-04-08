module Searchlight
  module DSL

    def search_on(target)
      @search_target = target
    end

    def searches(*attribute_names)
      include_new_module "SearchlightAccessors" do
        attr_accessor *attribute_names

        # define boolean accessors
        attribute_names.each do |attribute_name|
          define_method("#{attribute_name}?") do
            # Treat 0 (eg, from checkboxes) as false
            !['0', 'false', ''].include?(public_send(attribute_name).to_s.strip) 
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
