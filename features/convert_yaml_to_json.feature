Feature: Convert YAML to JSON
    As a JSON provider
    I want to generate my JSON from YAML
    So that it's easier to read

    Scenario: Basic array conversion
        Given I have a file "list.yml" containing
        """
        list:
            - One
            - 2
            - "3"
        """
        When I process "list.yml"
        Then the output should match JSON
        """
        {
            "AWSTemplateFormatVersion" : "2010-09-09",
            "list" : ["One", 2, "3"]
        }
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
            "AWSTemplateFormatVersion" : "2010-09-09",
            "1" : "One",
            "2" : "Two",
            "3" : "Three"
        }
        """

    Scenario: Embedded map structure
        Given I have a file "embeddedmap.yml" containing
        """
        Fruit:
            - Apples: [ red, green ]
            - Bananas
            - Grapes: [ seeded, seedless ]
        Vegetables:
            - Beans: [ red, black ]
            - Sweet Corn
            - Mirleton
        """
        When I process "embeddedmap.yml"
        Then the output should match JSON
        """
        {
            "AWSTemplateFormatVersion" : "2010-09-09",
            "Fruit": [
                { "Apples": [ "red", "green" ] },
                "Bananas",
                { "Grapes": [ "seeded", "seedless" ] }
            ],
            "Vegetables": [
                { "Beans": [ "red", "black" ] },
                "Sweet Corn",
                "Mirleton"
            ]
        }
        """
