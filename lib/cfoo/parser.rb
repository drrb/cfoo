class Object
    def expand_el
        self
    end
end

class String
    def expand_el
        case self
        when /^\$\([^)]*\)$/
            reference = sub /^\$\((.*)\)$/, '\1'
            if reference.include? "."
                { "Fn::GetAtt" => reference.split(".") }
            else
                { "Ref" => reference }
            end
        when /\$\(.*\)/
            parts = non_greedy_split /\$\((.*?)\)/
            { "Fn::Join" => [ "", parts.expand_el ] }
        else
            self
        end
    end

    def non_greedy_split(regex)
        parsing = self
        parsed = []
        until parsing.empty?
            parts = parsing.rpartition regex
            parsed = parts[1..2] + parsed
            parsing = parts[0]
        end
        parts = parsed.reject {|e| e.empty?}
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

module Cfoo
    class Parser
        def initialize(file_system)
            @file_system = file_system
        end

        def parse_file(file_name)
            @file_system.parse_file(file_name).expand_el
        end
    end
end
