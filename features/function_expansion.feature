Feature: Expand Function Calls
    As a CloudFormation user
    I want to use an expression language as a shorthand for function calls
    So that I my templates are easier to read

    Scenario: Function with no parameters
        Given I have a file "autoscaling_group.yml" containing
        """
        WebServerGroup:
           Type: AWS::AutoScaling::AutoScalingGroup
           Properties:
               AvailabilityZones: $(GetAZs())
        """
        When I process "autoscaling_group.yml"
        Then the output should match JSON
        """
        {
            "AWSTemplateFormatVersion" : "2010-09-09",
            "WebServerGroup" : {
               "Type" : "AWS::AutoScaling::AutoScalingGroup",
               "Properties" : {
                 "AvailabilityZones" : { "Fn::GetAZs" : ""}
               }
            }
        }
        """
