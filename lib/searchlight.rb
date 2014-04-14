require 'named'
require 'searchlight/version'

module Searchlight
  Error = Class.new(StandardError)
end

require 'searchlight/dsl'
require 'searchlight/search'
if defined?(::ActionView) && defined?(::ActiveModel)
  require 'searchlight/adapters/action_view'
end
