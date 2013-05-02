require 'cfoo/yaml_parser'

module Cfoo
    class FileSystem
        def initialize(project_root, yaml_parser)
            @project_root, @yaml_parser = project_root, yaml_parser
        end

        def resolve_file(file_name)
            "#{@project_root}/#{file_name}"
        end

        def parse_file(file_name)
            @yaml_parser.load_file(resolve_file file_name)
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
