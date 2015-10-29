require 'capybara/rspec'
require 'searchlight'
$LOAD_PATH << '.'
require 'support/mock_model'
require 'support/book_search'
require 'support/fancy_hash'

RSpec.configure do |config|
  config.run_all_when_everything_filtered = true
  config.filter_run :focus

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = 'random'
end
