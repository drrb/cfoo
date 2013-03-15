module Cfml
    class Processor
        def initialize(project)
            @project = project
        end

        def process(filename)
            data_structure = @project.parse_file filename
            if data_structure.class == Array
                data_structure.map do |element|
                    element.class == String ? expand_el(element) : element
                end
            else
                data_structure
            end
        end

        #TODO: what if it's not a string
        def expand_el(string)
            content = string.sub /^\$\{(.*)\}$/, '\1'
            if content == string
                string
            else
                { "Ref" => content }
            end
        end
    end
end
