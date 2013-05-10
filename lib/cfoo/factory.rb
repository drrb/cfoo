require "cfoo/cfoo"
require "cfoo/file_system"
require "cfoo/parser"
require "cfoo/processor"
require "cfoo/project"
require "cfoo/renderer"
require "cfoo/yaml_parser"

module Cfoo
    class Factory
        def initialize(stdout, stderr)
            @stdout, @stderr = stdout, stderr
        end

        def cfoo
            yaml_parser = YamlParser.new
            file_system = FileSystem.new(".", yaml_parser)
            project = Project.new(file_system)
            parser = Parser.new(file_system)
            processor = Processor.new(parser, project)
            renderer = Renderer.new
            cfoo = Cfoo.new(processor, renderer, @stdout, @stderr)
        end
    end
end
