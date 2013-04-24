module Cfoo
    class Cfoo
        def initialize(processor, renderer, stdout)
            @processor, @renderer, @stdout = processor, renderer, stdout
        end

        def process(*filenames)
            @stdout.puts(@renderer.render @processor.process(*filenames))
        end

        def build_project
            @stdout.puts(@renderer.render @processor.process_all)
        end
    end
end
