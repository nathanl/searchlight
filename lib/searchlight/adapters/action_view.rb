require 'action_view'
require 'active_model'
require 'active_support/core_ext'

module Searchlight
  module Adapters
    module ActionView

      include ::ActiveModel::Conversion

      def self.included(search_class)
        search_class.extend ::ActiveModel::Naming
      end

      def persisted?
        false
      end

    end
  end
end
