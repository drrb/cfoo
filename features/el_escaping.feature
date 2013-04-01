Feature: EL escaping
    As a CloudFormation user
    I want to to be able to escape the EL
    So that I can type whatever text I want

    Scenario: Escape EL
        Given I have a file "outputs.yml" containing
        """
        EntryPoint:
            Value: \$(BastionHost.PublicIp)
        """
        When I process "outputs.yml"
        Then the output should match JSON
        """
        {
            "EntryPoint" : {
                "Value" : "$(BastionHost.PublicIp)"
            }
        }
        """
