Feature: Expand EL
    As a CloudFormation user
    I want to use an expression language as a shorthand for references
    So that I my templates are easier to read

    Scenario: Simple reference
        Given I have a file "reference.yml" containing
        """
        - One
        - ${Two}
        - Three
        """
        When I process "reference.yml"
        Then the output should match JSON
        """
        [ "One", {"Ref":"Two"}, "Three" ]
        """

    Scenario: Attribute resolution
        Given I have a file "attribute.yml" containing
        """
        - Red
        - ${Banana.Color}
        - Blue
        """
        When I process "attribute.yml"
        Then the output should match JSON
        """
        [
            "Red",
            {"Fn::GetAtt" : ["Banana" , "Color"]},
            "Blue"
        ]
        """
