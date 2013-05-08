require 'cfoo/constants'
require 'cfoo/el_parser'
require 'cfoo/yaml'

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
        class ElParseError < RuntimeError
            def initialize(message, parslet_failure = nil)
                super(message)
                @parslet_failure = parslet_failure
            end

            def message
                if @parslet_failure
                    super + "\n#{@parslet_failure.cause.ascii_tree}"
                else
                    super
                end
            end
        end

        def initialize(file_system)
            @file_system = file_system
        end

        def parse_file(file_name)
            @file_system.parse_file(file_name).expand_el
        rescue Parslet::ParseFailed => failure
           raise ElParseError.new("Failed to parse '#{file_name}':", failure)
        end
    end
end
