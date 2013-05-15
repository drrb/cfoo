Feature: Error reporting
    As a Cfoo user
    I want to get useful parse errors
    So that I can debug my templates

    Scenario: YAML Parse error
        Given I have a file "bad_yaml.yml" containing
        """
        EntryPoint: Key: Value:
        """
        When I process "bad_yaml.yml"
        Then I should see an error containing "bad_yaml.yml"
        And I should see an error containing "line"
        And I should see an error containing "col"

    Scenario: EL Parse error
        Given I have a file "bad_el.yml" containing
        """
        EntryPoint: $(
        """
        When I process "bad_el.yml"
        Then I should see an error containing "Source: $("
        And I should see an error containing "Location: bad_el.yml line 1, column 13"
