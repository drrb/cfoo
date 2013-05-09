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
                 "AvailabilityZones" : { "Fn::GetAZs" : "" }
               }
            }
        }
        """

    Scenario: Function with one parameter
        Given I have a file "autoscaling_group.yml" containing
        """
        WebServerGroup:
           Type: AWS::AutoScaling::AutoScalingGroup
           Properties:
               AvailabilityZones: $(GetAZs(us-east-1))
        """
        When I process "autoscaling_group.yml"
        Then the output should match JSON
        """
        {
            "AWSTemplateFormatVersion" : "2010-09-09",
            "WebServerGroup" : {
               "Type" : "AWS::AutoScaling::AutoScalingGroup",
               "Properties" : {
                 "AvailabilityZones" : { "Fn::GetAZs" : "us-east-1" }
               }
            }
        }
        """

    Scenario: Function with multiple parameters
        Given I have a file "autoscaling_group.yml" containing
        """
        FrontendFleet:
            Type: AWS::AutoScaling::AutoScalingGroup
            Properties:
                AvailabilityZones:
                    - $(GetAtt(PrivateSubnet, AvailabilityZone))
        """
        When I process "autoscaling_group.yml"
        Then the output should match JSON
        """
        {
            "AWSTemplateFormatVersion" : "2010-09-09",
            "FrontendFleet" : {
                "Type" : "AWS::AutoScaling::AutoScalingGroup",
                "Properties" : {
                    "AvailabilityZones" : [{ "Fn::GetAtt" : [ "PrivateSubnet", "AvailabilityZone" ] }]
                }
            }
        }
        """

    Scenario: Function with no spaces between arguments
        Given I have a file "autoscaling_group.yml" containing
        """
        FrontendFleet:
            Type: AWS::AutoScaling::AutoScalingGroup
            Properties:
                AvailabilityZones:
                    - $(GetAtt(PrivateSubnet,AvailabilityZone))
        """
        When I process "autoscaling_group.yml"
        Then the output should match JSON
        """
        {
            "AWSTemplateFormatVersion" : "2010-09-09",
            "FrontendFleet" : {
                "Type" : "AWS::AutoScaling::AutoScalingGroup",
                "Properties" : {
                    "AvailabilityZones" : [{ "Fn::GetAtt" : [ "PrivateSubnet", "AvailabilityZone" ] }]
                }
            }
        }
        """

    Scenario: Function with lots of spaces between and around arguments
        Given I have a file "autoscaling_group.yml" containing
        """
        FrontendFleet:
            Type: AWS::AutoScaling::AutoScalingGroup
            Properties:
                AvailabilityZones:
                    - $(GetAtt(  PrivateSubnet  ,  AvailabilityZone  ))
        """
        When I process "autoscaling_group.yml"
        Then the output should match JSON
        """
        {
            "AWSTemplateFormatVersion" : "2010-09-09",
            "FrontendFleet" : {
                "Type" : "AWS::AutoScaling::AutoScalingGroup",
                "Properties" : {
                    "AvailabilityZones" : [{ "Fn::GetAtt" : [ "PrivateSubnet", "AvailabilityZone" ] }]
                }
            }
        }
        """

    Scenario: Function with embedded EL
        Given I have a file "app_servers.yml" containing
        """
        AppServerLaunchConfig:
            Type: AWS::AutoScaling::LaunchConfiguration
            Properties:
                ImageId: $(FindInMap(AWSRegionArch2AMI, $(AWS::Region), $(AWSInstanceType2Arch[$(FrontendInstanceType)][Arch])))
        """
        When I process "app_servers.yml"
        Then the output should match JSON
        """
        {
            "AWSTemplateFormatVersion" : "2010-09-09",
            "AppServerLaunchConfig" : {
                "Type": "AWS::AutoScaling::LaunchConfiguration",
                "Properties" : {
                    "ImageId": { "Fn::FindInMap" : [ "AWSRegionArch2AMI", { "Ref" : "AWS::Region" }, { "Fn::FindInMap" : [ "AWSInstanceType2Arch", { "Ref" : "FrontendInstanceType" }, "Arch" ] } ] }
                }
            }
        }
        """
