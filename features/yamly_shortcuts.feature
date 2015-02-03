Feature: YAMLy shortcuts
    I should be able to write standalone (non-embedded) CloudFormation bits using custom YAML datatypes
    So that I can have a quick YAMLy way to write them
    
    Scenario: Reference
        Given I have a file "ref.yml" containing
        """
        Reference: !Ref AWS::Region
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
        Given I have a file "getatt.yml" containing
        """
        Attribute: !GetAtt [ BastionHost, PublicIp ]
        """
        When I process "getatt.yml"
        Then the output should match JSON
        """
        {
            "AWSTemplateFormatVersion" : "2010-09-09",
            "Attribute" :  { "Fn::GetAtt" : [ "BastionHost", "PublicIp" ]}
        }
        """

    Scenario: Condition
        Given I have a file "cond.yml" containing
        """
        Condition: !Equals [ "string a", "string b" ]
        """
        When I process "cond.yml"
        Then the output should match JSON
        """
        {
            "AWSTemplateFormatVersion" : "2010-09-09",
            "Condition": { "Fn::Equals" : [ "string a", "string b" ]}
        }
        """

    Scenario: Join function call
        Given I have a file "join.yml" containing
        """
        Join: !Join
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
        Join: !Concat [ "string a", "string b" ]
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
        MapLookup: !FindInMap [Map, Key, Value]
        """
        When I process "map.yml"
        Then the output should match JSON
        """
        {
            "AWSTemplateFormatVersion" : "2010-09-09",
            "MapLookup" : { "Fn::FindInMap" : ["Map", "Key", "Value"] }
        }
        """

    Scenario: AZ listing
        Given I have a file "map.yml" containing
        """
        AvailabilityZones: !GetAZs us-east-1
        """
        When I process "map.yml"
        Then the output should match JSON
        """
        {
            "AWSTemplateFormatVersion" : "2010-09-09",
            "AvailabilityZones" : { "Fn::GetAZs" : "us-east-1" }
        }
        """

    Scenario: Base64 string
        Given I have a file "multistring.yml" containing
        """
        mystring: !Base64 |
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
        mystring: !Base64 |
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
