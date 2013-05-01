require 'cfoo/yaml'

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
            #TODO: move these into a dedidated YAML parser
            YAML.add_domain_type "", "Ref" do |tag,value|
                YAML::DomainType.create("Ref", value)
            end 
            YAML.add_domain_type "", "Join" do |tag,value|
                YAML::DomainType.create("Join", value)
            end 
            YAML.add_domain_type "", "Concat" do |tag,value|
                YAML::DomainType.create("Concat", value)
            end 
            YAML.add_domain_type "", "GetAtt" do |tag,value|
                YAML::DomainType.create("GetAtt", value)
            end 
            YAML.add_domain_type "", "FindInMap" do |tag,value|
                YAML::DomainType.create("FindInMap", value)
            end 
            YAML.add_domain_type "", "Base64" do |tag,value|
                YAML::DomainType.create("Base64", value)
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
