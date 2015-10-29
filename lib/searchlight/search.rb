require_relative "options"

class Searchlight::Search

  SEARCH_METHOD_PATTERN = /\Asearch_(?<option>.*)/

  attr_accessor :query
  attr_reader   :raw_options

  def self.method_added(method_name)
    method_name.to_s.match(SEARCH_METHOD_PATTERN) do |match|
      option_name = match.captures.fetch(0)
      # accessor - eg, if method_name is #search_title, define #title
      define_method(option_name) do
        options.key?(option_name) ? options[option_name] : options[option_name.to_sym]
      end
    end
  end

  def initialize(raw_options = {})
    string_keys, non_string_keys = raw_options.keys.partition {|k| k.is_a?(String) }
    intersection = string_keys & non_string_keys.map(&:to_s)
    if intersection.any?
      fail ArgumentError, "more than one key converts to these string values: #{intersection}"
    end
    @raw_options = raw_options
  end

  def results
    @results ||= run
  end

  def options
    Searchlight::Options.excluding_empties(raw_options)
  end

  def empty?(value)
    Searchlight::Options.empty?(value)
  end

  def checked?(value)
    Searchlight::Options.checked?(value)
  end

  def explain
    [
      "Initialized with `raw_options`: #{raw_options.keys.inspect}",
      "Of those, the non-blank ones are available as `options`: #{options.keys.inspect}",
      "Of those, the following have corresponding `search_` methods: #{options_with_search_methods.keys}. These would be used to build the query.",
      "Blank options are: #{(raw_options.keys - options.keys).inspect}",
      "Non-blank options with no corresponding `search_` method are: #{options.keys - options_with_search_methods.keys}",
    ].join("\n\n")
  end

  def options_with_search_methods
    {}.tap do |map|
      options.each do |option_name, _|
        method_name = "search_#{option_name}" 
        map[option_name] = method_name if respond_to?(method_name)
      end
    end
  end

  private

  def run
    self.query = base_query
    options_with_search_methods.each do |option, method_name|
      self.query = public_send(method_name)
    end
    query
  end

end
