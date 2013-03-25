class Object
    def expand_el
        self
    end
end

class String
    def expand_el
        case self
        when /^\$\([^)]*\)$/
            reference = sub /^\$\((.*)\)$/, '\1'
            if reference.include? "."
                { "Fn::GetAtt" => reference.split(".") }
            else
                { "Ref" => reference }
            end
        when /\$\(.*\)/
            parts = non_greedy_split /\$\((.*?)\)/
            { "Fn::Join" => [ "", parts.expand_el ] }
        else
            self
        end
    end

    def non_greedy_split(regex)
        parsing = self
        parsed = []
        until parsing.empty?
            parts = parsing.rpartition regex
            parsed = parts[1..2] + parsed
            parsing = parts[0]
        end
        parts = parsed.reject {|e| e.empty?}
    end
end

class Array
    def expand_el
        map {|element| element.expand_el }
    end
end

class Hash
    def expand_el
        Hash[map do |key, value|
            [ key, value.expand_el ]
        end]
    end

    def deep_merge(other)                                                            
        merge(other) do |key, our_item, their_item|                                  
            if our_item.respond_to? :deep_merge                                      
                our_item.deep_merge(their_item)                                      
            elsif our_item.respond_to? :concat                                       
                our_item.concat(their_item).uniq                                     
            else                                                                     
                their_item                                                           
            end                                                                      
        end                                                                          
    end
end

module Cfoo
    class Processor
        def initialize(project)
            @project = project
        end

        def process(filename)
            data_structure = @project.parse_file filename
            data_structure.expand_el
        end

        def process_all
            project_map = { "AWSTemplateFormatVersion" => "2010-09-09" }
            @project.modules.each do |mod|
                mod.files.each do |file|
                    module_map = process file
                    project_map = project_map.deep_merge module_map
                end
            end
            #TODO: expand el 
            project_map
        end
    end
end
