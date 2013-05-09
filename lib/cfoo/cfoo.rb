module Cfoo
    class Cfoo
        def initialize(processor, renderer, stdout, stderr)
            @processor, @renderer, @stdout, @stderr = processor, renderer, stdout, stderr
        end

        def process(*filenames)
            @stdout.puts(@renderer.render @processor.process(*filenames))
        rescue Exception => error
            @stderr.puts error
        end

        def build_project
            @stdout.puts(@renderer.render @processor.process_all)
        rescue Exception => error
            @stderr.puts error
        end
    end
end
