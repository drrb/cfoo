
class Hash
    def deep_merge(other)
        merge(other) do |key, our_item, their_item|
            if [our_item, their_item].all? {|item| item.respond_to? :deep_merge }
                our_item.deep_merge(their_item)
            elsif [our_item, their_item].all? {|item| item.respond_to?(:+) && item.respond_to?(:uniq) }
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

        def process(*filenames)
            project_map = { "AWSTemplateFormatVersion" => "2010-09-09" }
            filenames.each do |filename|
                module_map = @parser.parse_file filename
                project_map = project_map.deep_merge module_map
            end
            project_map
        end

        def process_all
            project_files = @project.modules.inject([]) do |all_files, mod|
                all_files += mod.files
            end
            process *project_files
        end
    end
end
