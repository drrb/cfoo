class Object
    def expand_el
        raise Cfoo::Parser::ElParseError, "Couldn't parse object '#{self}'. I don't know how to parse an instance of '#{self.class}'"
    end
end

class Fixnum
    def expand_el
        self
    end
end

class FalseClass
    def expand_el
        to_s
    end
end

class TrueClass
    def expand_el
        to_s
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
            if reference.include? "."
                { "Fn::GetAtt" => reference.split(".") }
            else
                { "Ref" => reference }
            end
        end
    end
end

class String
    def expand_el
        contains_el = self =~ /\$\(.*\)/
        unless contains_el
            return self
        end

        parts = partition_split /\\?\$\((.*?)\)/
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
        class ElParseError < RuntimeError
        end

        def initialize(file_system)
            @file_system = file_system
        end

        def parse_file(file_name)
            @file_system.parse_file(file_name).expand_el
        end
    end
end
