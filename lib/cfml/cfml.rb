require 'json'

module Cfml
    class Cfml
        def initialize(processor, stdout)
            @processor, @stdout = processor, stdout
        end

        def process(filename)
            @stdout.puts(JSON.pretty_unparse @processor.process(filename))
        end
    end
end
