require 'cfoo/yaml_parser'

class String
    def coordinates_of_index(index)
        lines = split("\n")
        line_number = 1
        column_number = index + 1
        lines.each do |line|
            if line.length < column_number
                line_number += 1
                column_number -= line.length
            else
                return [ line_number, column_number ]
            end
        end
        [ -1, -1 ]
    end
end

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
            open(file_name) do |file|
                content = file.read
                lines = string.split "\n"
                patterns = lines.map { |line| Regexp.escape(line) }
                pattern = patterns.join '\n\s*'
                regex = %r[#{pattern}]
                index = regex =~ content
                if index.nil?
                    raise CoordinatesNotFound, "Couldn't find '#{string.inspect}' in '#{file_name}'"
                else
                    content.coordinates_of_index(index)
                end
            end
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

    class CoordinatesNotFound < StandardError
    end
end
