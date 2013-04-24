Feature: Modules
    As a casual Cfoo user
    I want to combine arbitrary Cfoo templates
    So that I can quickly generate a CloudFormation template without a project structure

    Scenario: Parse files
        Given I have a file "webapp.yml" containing
        """
        Resources:
            FrontendFleet:                                                                                                                                               
                Type: AWS::AutoScaling::AutoScalingGroup                                         
                Properties:                                                                         
                    MinSize: 1                                                                      
                    MaxSize: 10                                                                     
        """
        And I have a file "vpc.yml" containing
        """
        Resources:
            VPC:
                Type: AWS::EC2::VPC
                Properties:
                    CidrBlock: "10.0.0.0/16"
        """
        When I process files "webapp.yml" and "vpc.yml"
        Then the output should match JSON
        """
        {
            "AWSTemplateFormatVersion" : "2010-09-09",
            "Resources" : {
                "FrontendFleet" : {
                    "Type" : "AWS::AutoScaling::AutoScalingGroup",
                    "Properties" : {
                        "MinSize" : 1,
                        "MaxSize" : 10
                    }
                },
                "VPC" : {
                    "Type" : "AWS::EC2::VPC",
                    "Properties" : {
                        "CidrBlock" : "10.0.0.0/16"
                    }
                }
            }
        }
        """
            
