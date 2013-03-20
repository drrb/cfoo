require 'yaml'

module Cfoo
    class Project
        def initialize(project_root)
            @project_root = project_root
        end

        def resolve_file(file_name)
            "#{@project_root}/#{file_name}"
        end

        def parse_file(file_name)
            YAML.load_file(resolve_file file_name)
        end
    end
end
