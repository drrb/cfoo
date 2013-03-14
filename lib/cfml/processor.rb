module Cfml
    class Processor
        def initialize(project)
            @project = project
        end

        def process(filename)
            @project.parse_file filename
        end
    end
end
