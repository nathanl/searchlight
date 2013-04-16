require 'named'
require 'searchlight/version'

module Searchlight
  Error = Class.new(StandardError)
end

require 'searchlight/dsl'
require 'searchlight/search'
require 'searchlight/adapters/active_record' if defined?(::ActiveRecord)
require 'searchlight/adapters/action_view'   if defined?(::ActionView)
