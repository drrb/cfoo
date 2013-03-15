class Object
    def expand_el
        self
    end
end

class String
    def expand_el
        case self
        when /^\$\{.*\}$/
            reference = sub /^\$\{(.*)\}$/, '\1'
            { "Ref" => reference }
        when /\$\{.*\}/
            parts = rpartition /\$\{.*\}/
            { "Fn::Join" => [""] + parts.expand_el }
        else
            self
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
