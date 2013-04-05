module Pilfer
  module Adapters
    module ActiveRecord

      def search_on(target)
        super
        extend Search if target.is_a?(::ActiveRecord::Base)
      end

      module Search
        def searches(*attribute_names)
          super

          include_new_module "PilferActiveRecordSearches" do
            attribute_names.each do |attribute_name|
              define_method("search_#{attribute_name}") do
                search.where(attribute_name => public_send(attribute_name))
              end
            end
          end

          attribute_names.each { |attribute_name| method_added("search_#{attribute_name}") }
        end
      end

    end
  end
end

Pilfer::Search.extend(Pilfer::Adapters::ActiveRecord)
