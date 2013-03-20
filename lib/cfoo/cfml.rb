require 'json'

module Cfoo
    class Cfoo
        def initialize(processor, stdout)
            @processor, @stdout = processor, stdout
        end

        def process(filename)
            @stdout.puts(JSON.pretty_unparse @processor.process(filename))
        end
    end
end
