require 'named'
require 'pilfer/version'

module Pilfer
end

require 'pilfer/coercer'
require 'pilfer/dsl'
require 'pilfer/search'
require 'pilfer/adapters/active_record' if defined?(ActiveRecord)
