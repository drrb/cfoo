require 'yaml'

module Cfoo
    class Module
        attr_reader :dir

        def initialize(dir, file_system)
            @dir, @file_system = dir, file_system
        end

        def files
            @file_system.list_relative(dir)
        end

        def ==(other)
            eql? other
        end

        def eql?(other)
            dir = other.dir
        end
        
        def to_s
            "Module[#{dir}]"
        end
    end

    class FileSystem
        def initialize(project_root)
            @project_root = project_root
        end

        def resolve_file(file_name)
            "#{@project_root}/#{file_name}"
        end

        def parse_file(file_name)
            YAML.load_file(resolve_file file_name)
        end

        def list_relative(path)
            files = Dir.new(resolve_file path).reject {|f| f =~ /^[.][.]?$/ }
            files.map do |file|
                File.join(path, file)
            end
        end|

        def list(path)
            Dir.glob("#{resolve_file path}/*")
        end
    end

    class Project
        def initialize(file_system)
            @file_system = file_system 
        end

        def parse_file(file_name)
            @file_system.parse_file(file_name)
        end

        def modules
            module_dirs = @file_system.list_relative("modules")
            module_dirs.map do |dir|
                Module.new(dir, @file_system)
            end
        end
    end
end
