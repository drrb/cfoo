Feature: Expand EL Mapping References
    As a CloudFormation user
    I want to use an expression language as a shorthand for mapping references
    So that I my templates are easier to read

    Scenario: Map reference expansion
        Given I have a file "outputs.yml" containing
        """
        EntryPoint:
            Description: IP address of the Bastion Host
            Value: $(SubnetConfig[VPC][CIDR])
        """
        When I process "outputs.yml"
        Then the output should match JSON
        """
        {
            "AWSTemplateFormatVersion" : "2010-09-09",
            "EntryPoint" : {
                "Description" : "IP address of the Bastion Host",
                "Value" :  { "Fn::FindInMap" : [ "SubnetConfig", "VPC", "CIDR" ]}
            }
        }
        """

    Scenario: Embedded map reference expansion
        Given I have a file "outputs.yml" containing
        """
        WebSite:
            Description: URL of the website
            Value: http://$(Network[Dns][LoadBalancerDnsName])/index.html
        """
        When I process "outputs.yml"
        Then the output should match JSON
        """
        {
            "AWSTemplateFormatVersion" : "2010-09-09",
            "WebSite" : {                                                                                                                                            
                "Description" : "URL of the website",
                "Value" :  { "Fn::Join" : [ "", [ "http://", { "Fn::FindInMap" : [ "Network", "Dns", "LoadBalancerDnsName" ]}, "/index.html"]]}
            }
        }
        """

    Scenario: Map key is reference
        Given I have a file "nat.yml" containing
        """
        Resources:
            NATDevice:
                Type: AWS::EC2::Instance
                Properties:
                    ImageId: $(AWSNATAMI[$(AWS::Region)][AMI])
        """
        When I process "nat.yml"
        Then the output should match JSON
        """
        {
            "AWSTemplateFormatVersion" : "2010-09-09",
            "Resources" : {
                "NATDevice" : {
                    "Type" : "AWS::EC2::Instance",
                    "Properties" : {
                        "ImageId" : { "Fn::FindInMap" : [ "AWSNATAMI" , { "Ref" : "AWS::Region" } , "AMI" ] }
                    }
                }
            }
        }
        """

