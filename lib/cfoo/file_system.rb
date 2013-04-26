require 'yaml'

module Cfoo
    class FileSystem
        def initialize(project_root)
            @project_root = project_root
        end

        def resolve_file(file_name)
            "#{@project_root}/#{file_name}"
        end

        def parse_file(file_name)
            #TODO: this only works in Ruby 1.9+
            YAML.add_builtin_type "base64" do |tag,value|
              { "Fn::Base64" => value }
            end 
            YAML.load_file(resolve_file file_name)
        end

        def glob_relative(path)
            absolute_files = Dir.glob(resolve_file path)
            absolute_files.map do |file|
                file.gsub(@project_root + '/', '')
            end
        end

        def list(path)
            Dir.glob("#{resolve_file path}/*")
        end
    end
end
