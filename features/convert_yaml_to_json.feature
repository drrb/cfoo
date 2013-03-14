Feature: Convert YAML to JSON
    As a JSON provider
    I want to generate my JSON from YAML
    So that it's easier to read

    Scenario: Basic array conversion
        Given I have a file "list.yml" containing
        """
        - One
        - Two
        - Three
        """
        When I process "list.yml"
        Then the output should match JSON
        """
        [ "One", "Two", "Three" ]
        """

    Scenario: Basic map conversion
        Given I have a file "map.yml" containing
        """
        1: One
        2: Two
        3: Three
        """
        When I process "map.yml"
        Then the output should match JSON
        """
        {
           "1" : "One",
           "2" : "Two",
           "3" : "Three"
        }
        """

