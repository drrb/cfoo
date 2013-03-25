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
            YAML.load_file(resolve_file file_name)
        end

        def list_relative(path)
            files = list(path).map {|f| File.basename f}
            files.map do |file|
                File.join(path, file)
            end
        end|

        def list(path)
            Dir.glob("#{resolve_file path}/*")
        end
    end
end
