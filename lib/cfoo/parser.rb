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
        Cfoo::ExpressionLanguage.parse(self)
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
      def expand_el
         case type_id
         when "ref"
            { "Ref" => value.expand_el }
         when "join"
            { "Fn::Join" => value.expand_el }
         when "concat"
            { "Fn::Join" => ['', value.expand_el] }
         when "getatt"
            { "Fn::GetAtt" => value.expand_el }
         when "findinmap"
            { "Fn::FindInMap" => value.expand_el }
         when "base64"
            { "Fn::Base64" => value.expand_el }
         else
            super
         end 
      end
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
