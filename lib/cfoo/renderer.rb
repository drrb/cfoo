require 'json'

module Cfoo
    class Renderer
        def render(hash)
            JSON.pretty_unparse hash
        end
    end
end
