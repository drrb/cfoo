require 'yaml'

module Cfoo
    class FileSystem
        def initialize(project_root)
            @project_root = project_root
        end

        def resolve_file(file_name)
            "#{@project_root}/#{file_name}"
        end

        def parse_file(file_name)
            #TODO: these only work in Ruby 1.9+
            #TODO: raise errors if "value" isn't the right type
            #TODO: move these into a dedidated YAML parser
            YAML.add_builtin_type "ref" do |tag,value|
              { "Ref" => value }
            end 
            YAML.add_builtin_type "join" do |tag,value|
              { "Fn::Join" => value }
            end 
            YAML.add_builtin_type "concat" do |tag,value|
              { "Fn::Join" => ['', value] }
            end 
            YAML.add_builtin_type "getatt" do |tag,value|
              { "Fn::GetAtt" => value }
            end 
            YAML.add_builtin_type "findinmap" do |tag,value|
              { "Fn::FindInMap" => value }
            end 
            YAML.add_builtin_type "base64" do |tag,value|
              { "Fn::Base64" => value }
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
