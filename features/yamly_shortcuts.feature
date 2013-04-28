Feature: YAMLy shortcuts
    I should be able to write standalone (non-embedded) CloudFormation bits using custom YAML datatypes
    So that I can have a quick YAMLy way to write them
    
    Scenario: Reference
        Given I have a file "ref.yml" containing
        """
        Reference: !ref AWS::Region
        """
        When I process "ref.yml"
        Then the output should match JSON
        """
        {
            "AWSTemplateFormatVersion" : "2010-09-09",
            "Reference" : { "Ref" : "AWS::Region" }
        }
        """

    Scenario: Attribute
        Given I have a file "ref.yml" containing
        """
        Attribute: !getatt [ BastionHost, PublicIp ]
        """
        When I process "ref.yml"
        Then the output should match JSON
        """
        {
            "AWSTemplateFormatVersion" : "2010-09-09",
            "Attribute" :  { "Fn::GetAtt" : [ "BastionHost", "PublicIp" ]}
        }
        """

    Scenario: Join function call
        Given I have a file "join.yml" containing
        """
        Join: !join
            - ""
            - [ "string a", "string b" ]
        """
        When I process "join.yml"
        Then the output should match JSON
        """
        {
            "AWSTemplateFormatVersion" : "2010-09-09",
            "Join" :  { "Fn::Join" : [ "", [ "string a", "string b" ] ]}
        }
        """

    Scenario: Join function call with empty strings
        Given I have a file "join.yml" containing
        """
        Join: !concat [ "string a", "string b" ]
        """
        When I process "join.yml"
        Then the output should match JSON
        """
        {
            "AWSTemplateFormatVersion" : "2010-09-09",
            "Join" :  { "Fn::Join" : ["", [ "string a", "string b" ]]}
        }
        """

    Scenario: FindInMap lookup
        Given I have a file "map.yml" containing
        """
        MapLookup: !findinmap [Map, Key, Value]
        """
        When I process "map.yml"
        Then the output should match JSON
        """
        {
            "AWSTemplateFormatVersion" : "2010-09-09",
            "MapLookup" : { "Fn::FindInMap" : ["Map", "Key", "Value"] }
        }
        """

    Scenario: Base64 string
        Given I have a file "multistring.yml" containing
        """
        mystring: !base64 |
            Some string
            across multiple
            lines
        """
        When I process "multistring.yml"
        Then the output should match JSON
        """
        {
            "AWSTemplateFormatVersion" : "2010-09-09",
            "mystring" : { "Fn::Base64" : "Some string\nacross multiple\nlines\n" }
        }
        """

    Scenario: Base64 string with embedded EL
        Given I have a file "embeddedel.yml" containing
        """
        mystring: !base64 |
            Some string
            across $(Number)
            lines
        """
        When I process "embeddedel.yml"
        Then the output should match JSON
        """
        {
            "AWSTemplateFormatVersion" : "2010-09-09",
            "mystring" :
               { "Fn::Base64" :
                  { "Fn::Join": [ "", [
                           "Some string\nacross ",
                           { "Ref" : "Number" },
                           "\nlines\n"
                        ]
                     ]
                  }
               }
        }
        """
