class Object
    def expand_el
        self
    end
end

class String
    def expand_el
        content = sub /^\$\{(.*)\}$/, '\1'
        if content == self
            self
        else
            { "Ref" => content }
        end
    end
end

class Array
    def expand_el
        map {|element| element.expand_el }
    end
end

class Hash
    def expand_el
        Hash[map do |key, value|
            [ key, value.expand_el ]
        end]
    end
end

module Cfml
    class Processor
        def initialize(project)
            @project = project
        end

        def process(filename)
            data_structure = @project.parse_file filename
            data_structure.expand_el
        end
    end
end
