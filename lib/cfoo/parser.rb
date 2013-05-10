require 'cfoo/constants'
require 'cfoo/el_parser'
require 'cfoo/yaml'
require 'rubygems'
require 'parslet'

module Parslet
    class Source
        def str
            @str
        end
    end
end

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

class String
    def expand_el
        Cfoo::ElParser.parse(self)
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

module YAML
    class DomainType

        CLOUDFORMATION_FUNCTION_REGEX = %r[^(#{::Cfoo::CLOUDFORMATION_FUNCTIONS.join '|'})$]

        def expand_el
            case type_id
            when "Ref"
                { "Ref" => value.expand_el }
            when CLOUDFORMATION_FUNCTION_REGEX
                { "Fn::#{type_id}" => value.expand_el }
            when "Concat"
                { "Fn::Join" => ['', value.expand_el] }
            else
                super
            end 
        end
    end
end

module Cfoo
    class Parser
        #TODO: this doesn't only represent EL parsing errors. It wraps all parsing errors (below)
        class ElParseError < RuntimeError
        end

        def initialize(file_system)
            @file_system = file_system
        end

        def parse_file(file_name)
            @file_system.parse_file(file_name).expand_el
        rescue Parslet::ParseFailed => failure
            #TODO: unit test this somehow
            cause = failure.cause
            source = cause.source.str
            row, column = @file_system.find_coordinates(source, file_name)
            raise ElParseError, "Failed to parse '#{file_name}':\nSource: #{source}\nLocation: #{file_name} line #{row}, column #{column} \nCause: #{cause.ascii_tree}"
        rescue Exception => failure
            raise ElParseError, "Failed to parse '#{file_name}':\n#{failure}"
        end
    end
end
