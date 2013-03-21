Feature: Modules
    As a CloudFormation user
    I want to split my templates into logical modules
    So that I can organise them and share them

    Scenario: Module with raw template
        Given I have a project 
        And I have a module named "webapp"
        And I have a file "modules/webapp/webapp.yml" containing
        """
        Parameters:
            FrontendSize:
                Type: Integer
                Default: 5
        Resources:
            FrontendFleet:                                                                                                                                               
                Type: AWS::AutoScaling::AutoScalingGroup                                         
                Properties:                                                                         
                    MinSize: 1                                                                      
                    MaxSize: 10                                                                     
        """
        When I build the project
        Then the output should match JSON
        """
        {
            "AWSTemplateFormatVersion" : "2010-09-09",
            "Parameters" : {
                "FrontendSize" : { "Type" : "Integer", "Default" : 5 }
            },
            "Resources" : {
                "FrontendFleet" : {
                    "Type" : "AWS::AutoScaling::AutoScalingGroup",
                    "Properties" : {
                        "MinSize" : 1,
                        "MaxSize" : 10
                    }
                }
            }
        }
        """
            
