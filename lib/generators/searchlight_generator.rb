require 'fileutils'
class SearchlightGenerator < Rails::Generators::NamedBase
  source_root File.expand_path("../templates", __FILE__)

  def create_search_class
    append_config_to_file
    template "search_class.rb", "app/searches/#{file_name}_search.rb"
  end

  private
  def append_config_to_file
    tempfile = File.open("file.rb", 'w')
    f = File.new("config/application.rb")
    f.each do |line|
      tempfile << line
      if line.match(/class Application/)
        tempfile << "    config.autoload_paths += %W(\#{config.root}/searches)\n"
      end
    end
    f.close
    tempfile.close

    FileUtils.mv("file.rb", "config/application.rb")
  end
end
