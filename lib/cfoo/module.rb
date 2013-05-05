module Cfoo
    class Module
        attr_reader :dir

        def initialize(dir, file_system)
            @dir, @file_system = dir, file_system
        end

        def files
            @file_system.glob_relative("#{dir}/*.yml")
        end

        def ==(other)
            eql? other
        end

        def eql?(other)
            dir = other.dir
        end
    end
end
