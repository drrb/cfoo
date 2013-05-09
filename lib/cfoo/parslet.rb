require 'rubygems'
require 'parslet'

module Parslet
    class ParseFailed
        def render
            cause = @parslet_failure.cause
            "Source: #{cause.source.str}\nCause: #{cause.ascii_tree}"
        end
    end
end
