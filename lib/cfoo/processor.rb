
class Hash
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
        def initialize(parser, project)
            @parser, @project = parser, project
        end

        def process(filename)
            @parser.parse_file filename
        end

        def process_all
            project_map = { "AWSTemplateFormatVersion" => "2010-09-09" }
            @project.modules.each do |mod|
                mod.files.each do |file|
                    module_map = process file
                    project_map = project_map.deep_merge module_map
                end
            end
            project_map
        end
    end
end
