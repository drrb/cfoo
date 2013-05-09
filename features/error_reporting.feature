@wip
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

    Scenario: YAML Parse error
        Given I have a file "bad_yaml.yml" containing
        """
        EntryPoint: Key: Value:
        """
        When I process "bad_yaml.yml"
        Then I should see an error containing "bad_yaml.yml"
        And I should see an error containing "line"
        And I should see an error containing "col"
