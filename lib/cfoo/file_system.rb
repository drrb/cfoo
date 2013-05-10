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

        def open(file_name, &block)
            File.open(resolve_file(file_name), &block)
        end

        def find_coordinates(string, file_name)
            matching_lines = []
            open(file_name) do |file|
                file.each_with_index do|line, line_index|
                    if line.include? string
                        column_index = line.index(string)
                        matching_lines << [line_index + 1, column_index + 1]
                    end
                end
            end
            matching_line = matching_lines.first
            row = matching_line.first
            column = matching_line.last
            [row, column]
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
