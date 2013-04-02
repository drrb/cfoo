class String
    # finds all occurences of the regex
    # returns an array of the matches and the bits in between
    def partition_split(regex)
        parsing = self
        parsed = []
        until parsing.empty?
            parts = parsing.partition regex
            parsed = parsed + parts[0..1]
            parsing = parts[2]
        end
        parsed.reject {|e| e.empty?}
    end
end

module Cfoo
    class ElParser
        def parse(string)
            contains_el = string =~ /\$\(.*\)/
            unless contains_el
                return string
            end

            parts = string.partition_split /\\?\$\((.*?)\)/
            parts.map! do |part|
                part =~ /\\?\$\(.*\)/ ? ElToken.new(part) : part
            end

            # Unescape EL
            parts.map! do |part|
                if part.class == ElToken && part.escaped?
                    part.expand_el
                else
                    part
                end
            end

            # Join escaped EL with adjacent strings
            parts = parts.inject(['']) do |combined_parts, part|
                previous = combined_parts.pop
                if previous.class == String && part.class == String
                    combined_parts << previous + part
                else
                    combined_parts << previous << part
                end
            end

            # Expand the remaining EL
            parts.map! do |part|
                part.class == ElToken ? part.expand_el : part
            end

            parts.reject! {|part| part.empty? }

            if parts.size == 1
                parts.first
            else
                { "Fn::Join" => [ "", parts ] }
            end
        end
    end

    class ElToken
        def initialize(string)
            raise "Invalid EL: '#{string}'" unless string =~ /\A\\?\$\(.*\)\z/
            @string = string
        end

        def escaped?
            @string =~ /\A\\/
        end

        def expand_el
            if escaped?
                @string.sub /\A\\/, ''
            else
                reference = @string.sub /^\$\((.*)\)$/, '\1'
                case reference
                when /\A.*[.].*\[.*\]\z/
                    map, key_value = reference.split('.')[0..1]
                    key, boxed_value = key_value.partition(/\[.*\]/)[0..1]
                    value = boxed_value.sub(/\A\[(.*)\]\z/, '\1')
                    { "Fn::FindInMap" => [map, key, value] }
                when /\A.*[.].*\z/
                    { "Fn::GetAtt" => reference.split(".") }
                else
                    { "Ref" => reference }
                end
            end
        end
    end
end
