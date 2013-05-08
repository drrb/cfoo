require 'rubygems'
require 'parslet'
require 'cfoo/array'

module Cfoo
    class ElParser < Parslet::Parser

        def self.parse(string)
            return string if string.empty?

            parser = ElParser.new
            transform = ElTransform.new

            tree = parser.parse(string)
            transform.apply(tree)
        #rescue Parslet::ParseFailed => failure
        #    #TODO: handle this properly
        end

        rule(:space) { match('\s').repeat(1) }
        rule(:space?) { space.maybe }
        rule(:escaped_dollar) { str('\$').as(:escaped_dollar) }
        rule(:lone_backslash) { str('\\').as(:lone_backslash) }
        rule(:lparen) { str('(') >> space? }
        rule(:rparen) { str(')') }
        rule(:lbracket) { str('[') }
        rule(:rbracket) { str(']') }
        rule(:dot) { str('.') }
        rule(:comma) { str(",") >> space? }
        rule(:text_character) { match['^\\\\$'] }
        rule(:identifier) { match['a-zA-Z0-9_\-:'].repeat(1).as(:identifier) >> space? }
        rule(:text) { text_character.repeat(1).as(:text) }

        rule(:attribute_reference) do
            (
                expression.as(:reference) >> (
                    str(".") >> identifier.as(:attribute) |
                    str("[") >> expression.as(:attribute) >> str("]")
                )
            ).as(:attribute_reference)
        end
        rule(:mapping) do
            (
                expression.as(:map) >>
                str("[") >> expression.as(:key) >> str("]") >>
                str("[") >> expression.as(:value) >> str("]")
            ).as(:mapping)
        end
        rule(:function_call) do
            (
                identifier.as(:function) >>
                lparen >>
                (identifier >> (comma >> identifier).repeat).as(:arguments).maybe >>
                rparen
            ).as(:function_call)
        end
        rule(:reference) do
            expression.as(:reference)
        end

        rule(:expression) { el | identifier }
        rule(:el) do
            str("$(") >> ( mapping | attribute_reference | function_call | reference ) >> str(")")
        end
        rule(:string) do
            ( escaped_dollar | lone_backslash | el | text ).repeat.as(:string)
        end

        root(:string)
    end

    class ElTransform < Parslet::Transform

        rule(:escaped_dollar => simple(:dollar)) { "$" }
        rule(:lone_backslash => simple(:backslash)) { "\\" }

        rule(:identifier => simple(:identifier)) do
            identifier.str
        end

        rule(:text => simple(:text)) do
            text.str
        end

        rule(:reference => subtree(:reference)) do
            { "Ref" => reference }
        end

        rule(:attribute_reference => { :reference => subtree(:reference), :attribute => subtree(:attribute)}) do
            { "Fn::GetAtt" => [ reference, attribute ] }
        end

        rule(:function_call => { :function => simple(:function) }) do
            { "Fn::#{function}" => "" }
        end

        rule(:function_call => { :function => simple(:function), :arguments => simple(:argument) }) do
            { "Fn::#{function}" => argument }
        end

        rule(:function_call => { :function => simple(:function), :arguments => sequence(:arguments) }) do
            { "Fn::#{function}" => arguments }
        end

        rule(:mapping => { :map => subtree(:map), :key => subtree(:key), :value => subtree(:value)}) do
            { "Fn::FindInMap" => [map, key, value] }
        end

        rule(:string => subtree(:string_parts)) do
            # EL is parsed separately from other strings
            parts = string_parts.join_adjacent_strings

            if parts.size == 1
                parts.first
            else
                { "Fn::Join" => [ "", parts ] }
            end
        end
    end
end
