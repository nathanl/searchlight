module Searchlight
  module Adapters
    module ActiveRecord

      def search_on(target)
        super
        extend Search if target.is_a?(::ActiveRecord::Base) || target.is_a?(::ActiveRecord::Relation)
      end

      module Search
        def searches(*attribute_names)
          super

          include_new_module "SearchlightActiveRecordSearches" do
            attribute_names.each do |attribute_name|
              define_method("search_#{attribute_name}") do
                search.where(attribute_name => public_send(attribute_name))
              end
            end
          end
        end
      end

    end
  end
end

Searchlight::Search.extend(Searchlight::Adapters::ActiveRecord)
