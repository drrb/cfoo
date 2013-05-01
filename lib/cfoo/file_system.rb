require 'cfoo/yaml'

module YAML
    def self.add_domain_type_that_gets_loaded_like_in_ruby_1_8(domain_type)
        add_domain_type "", domain_type do |tag, value|
            DomainType.create(domain_type, value)
        end
    end
end

module Cfoo
    class FileSystem
        def initialize(project_root)
            @project_root = project_root
        end

        def resolve_file(file_name)
            "#{@project_root}/#{file_name}"
        end

        def parse_file(file_name)
            #TODO: raise errors if "value" isn't the right type
            #TODO: move these into a dedicated YAML parser
            cfn_domain_types = [ "GetAZs", "Ref", "Join", "Concat", "GetAtt", "FindInMap", "Base64" ]
            cfn_domain_types.each do |domain_type|
                YAML.add_domain_type_that_gets_loaded_like_in_ruby_1_8 domain_type
            end
            YAML.load_file(resolve_file file_name)
        end

        def glob_relative(path)
            absolute_files = Dir.glob(resolve_file path)
            absolute_files.map do |file|
                file.gsub(@project_root + '/', '')
            end
        end

        def list(path)
            Dir.glob("#{resolve_file path}/*")
        end
    end
end
