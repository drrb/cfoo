require 'rubygems'
require 'parslet'

module Cfoo
    class ElParserParslet < Parslet::Parser

        rule(:space) { match('\s') }
        rule(:space?) { space.maybe }
        rule(:dollar) { str('$') }
        rule(:escaped_dollar) { str('\$').as(:escaped_dollar) }
        rule(:lone_backslash) { str('\\').as(:lone_backslash) }
        rule(:lparen) { str('(') }
        rule(:rparen) { str(')') }
        rule(:lbracket) { str('[') }
        rule(:rbracket) { str(']') }
        rule(:dot) { str('.') }
        rule(:identifier) { match['a-zA-Z'].repeat(1).as(:identifier) }
        rule(:text) { match['^\\\\$'].repeat(1).as(:text) }
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
        rule(:reference) do
            expression.as(:reference)
        end

        rule(:expression) { el | identifier }
        rule(:el) do
            str("$(") >> ( mapping | attribute_reference | reference ) >> str(")")
        end
        rule(:string) do
            ( escaped_dollar | lone_backslash | el | text ).repeat
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

        rule(:mapping => { :map => subtree(:map), :key => subtree(:key), :value => subtree(:value)}) do
            { "Fn::FindInMap" => [map, key, value] }
        end

        rule(:attribute_reference => { :reference => subtree(:reference), :attribute => subtree(:attribute)}) do
            { "Fn::GetAtt" => [ reference, attribute ] }
        end
    end

    class ExpressionLanguage
        def self.parse(string)
            parser = ElParserParslet.new
            transform = ElTransform.new

            tree = parser.parse(string)
            parts = transform.apply(tree)
            if parts.class == Array 
                parts
            else
                [parts]
            end
        rescue Parslet::ParseFailed => failure
            #TODO: handle this properly
            raise failure
        end
    end
end
