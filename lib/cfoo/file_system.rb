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
            YAML.add_builtin_type "ref" do |tag,value|
                YAML::PrivateType.create("ref", value)
            end 
            YAML.add_builtin_type "join" do |tag,value|
                YAML::PrivateType.create("join", value)
            end 
            YAML.add_builtin_type "concat" do |tag,value|
                YAML::PrivateType.create("concat", value)
            end 
            YAML.add_builtin_type "getatt" do |tag,value|
                YAML::PrivateType.create("getatt", value)
            end 
            YAML.add_builtin_type "findinmap" do |tag,value|
                YAML::PrivateType.create("findinmap", value)
            end 
            YAML.add_builtin_type "base64" do |tag,value|
                YAML::PrivateType.create("base64", value)
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
