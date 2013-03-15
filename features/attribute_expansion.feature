Feature: Expand EL Reference Atributes
    As a CloudFormation user
    I want to use an expression language as a shorthand for references
    So that I my templates are easier to read

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
