Feature: base64 strings
    I should be able to write { "Fn::Base64" : "somestring" }

    Scenario: Base64 multiline string
        Given I have a file "multistring.yml" containing
        """
        mystring: !!base64 |
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

