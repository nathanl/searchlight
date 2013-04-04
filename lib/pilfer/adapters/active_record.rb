module Pilfer
  module Adapters
    module ActiveRecord

      def searches(*attribute_names)
        super

        include_new_module "PilferActiveRecordSearches" do
          attribute_names.each do |attribute_name|
            define_method("#{attribute_name}_search") do
              search.where(attribute_name => public_send(attribute_name))
            end
          end
        end

        attribute_names.each { |attribute_name| method_added("#{attribute_name}_search") }
      end

    end
  end
end

Pilfer::Search.extend(Pilfer::Adapters::ActiveRecord)
