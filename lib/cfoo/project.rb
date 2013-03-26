require 'cfoo/module'

module Cfoo
    class Project
        def initialize(file_system)
            @file_system = file_system 
        end

        def modules
            module_dirs = @file_system.glob_relative("modules/*")
            module_dirs.map do |dir|
                Module.new(dir, @file_system)
            end
        end
    end
end
