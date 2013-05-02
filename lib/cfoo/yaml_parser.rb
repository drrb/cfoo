require 'cfoo/yaml'

module Cfoo
    class YamlParser

        CFN_DOMAIN_TYPES = [ "GetAZs", "Ref", "Join", "Concat", "GetAtt", "FindInMap", "Base64" ]

        def load_file(file_name)
            #TODO: raise errors if "value" isn't the right type
            CFN_DOMAIN_TYPES.each do |domain_type|
                YAML.add_domain_type_that_gets_loaded_like_in_ruby_1_8(domain_type)
            end
            YAML.load_file(file_name)
        end
    end
end
