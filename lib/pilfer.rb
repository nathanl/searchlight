require 'named'
require 'pilfer/version'

module Pilfer
end

require 'pilfer/dsl'
require 'pilfer/search'
require 'pilfer/adapters/active_record' if defined?(::ActiveRecord)
require 'pilfer/adapters/action_view'   if defined?(::ActionView)
