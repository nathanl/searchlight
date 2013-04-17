module Searchlight
  module DSL

    def search_on(target)
      @search_target = target
    end

    def searches(*attribute_names)

      # Ensure this class only adds one accessors module to the ancestors chain
      if @accessors_module.nil?
        @accessors_module = Named::Module.new("SearchlightAccessors(#{self})") do
          private
          # Treat 0 (eg, from checkboxes) as false
          def truthy?(value)
            !(['0', 'false', ''].include?(value.to_s.strip))
          end
        end
        include @accessors_module
      end

      eval_string = "attr_accessor *#{attribute_names}\n"
      eval_string << attribute_names.map { |attribute_name|
        <<-LEPRECHAUN_JUICE
          def #{attribute_name}?
            truthy?(public_send("#{attribute_name}"))
          end
        LEPRECHAUN_JUICE
      }.join
      @accessors_module.module_eval(eval_string, __FILE__, __LINE__)
    end
  end
end
