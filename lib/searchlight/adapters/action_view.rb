module Searchlight
  module Adapters
    module ActionView

      module ClassMethods

        def model_name
          ::ActiveModel::Name.new(self, nil, 'search')
        end

      end

      module InstanceMethods

        def to_key
          []
        end

        def persisted?
          false
        end

      end

    end
  end
end

Searchlight::Search.send(:include, Searchlight::Adapters::ActionView::InstanceMethods)
Searchlight::Search.extend(Searchlight::Adapters::ActionView::ClassMethods)
