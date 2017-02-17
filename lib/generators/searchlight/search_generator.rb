module Searchlight
  module Generators
    class SearchGenerator < Rails::Generators::NamedBase
      desc 'This generator creates a new search class in app/searches'

      source_root File.expand_path('../templates', __FILE__)

      check_class_collision suffix: 'Search'

      def create_search_file
        template 'search.rb.erb', File.join('app/searches', class_path, "#{file_name}_search.rb")
      end
    end
  end
end
