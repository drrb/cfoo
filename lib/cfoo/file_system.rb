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
                file.each_with_index do|line, row_index|
                    if line.include? string
                        column_index = line.index(string)
                        row = row_index + 1
                        column = column_index + 1
                        return [row, column]
                    end
                end
            end
            #TODO test this
            raise "Couldn't find '#{string}' in '#{file}'"
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
