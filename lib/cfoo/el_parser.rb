require 'rubygems'
require 'parslet'

module Cfoo
    class ElParser < Parslet::Parser

        def self.parse(string)
            return string if string.empty?

            parser = ElParser.new
            transform = ElTransform.new

            tree = parser.parse(string)
            transform.apply(tree)
        rescue Parslet::ParseFailed => failure
            #TODO: handle this properly
            raise failure
        end

        rule(:space) { match('\s') }
        rule(:space?) { space.maybe }
        rule(:escaped_dollar) { str('\$').as(:escaped_dollar) }
        rule(:lone_backslash) { str('\\').as(:lone_backslash) }
        rule(:lparen) { str('(') }
        rule(:rparen) { str(')') }
        rule(:lbracket) { str('[') }
        rule(:rbracket) { str(']') }
        rule(:dot) { str('.') }
        rule(:identifier) { match['a-zA-Z:'].repeat(1).as(:identifier) }
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

        rule(:mapping => { :map => subtree(:map), :key => subtree(:key), :value => subtree(:value)}) do
            { "Fn::FindInMap" => [map, key, value] }
        end

        rule(:attribute_reference => { :reference => subtree(:reference), :attribute => subtree(:attribute)}) do
            { "Fn::GetAtt" => [ reference, attribute ] }
        end

        rule(:string => subtree(:string)) do
            # Join escaped EL with adjacent strings
            parts = string.inject(['']) do |combined_parts, part|
                previous = combined_parts.pop
                if previous.class == String && part.class == String
                    combined_parts << previous + part
                else
                    combined_parts << previous << part
                end
            end

            parts.reject! {|part| part.empty? }

            if parts.size == 1
                parts.first
            else
                { "Fn::Join" => [ "", parts ] }
            end
        end
    end
end
