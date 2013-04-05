module Pilfer
  module Adapters
    module ActionView

      module ClassMethods

        def model_name
          ActiveModel::Name.new(self, nil, 'query')
        end

      end

      module InstanceMethods

        def to_key
          []
        end

      end

    end
  end
end

Pilfer::Search.send(:include, Pilfer::Adapters::ActionView::InstanceMethods)
Pilfer::Search.extend(Pilfer::Adapters::ActionView::ClassMethods)
