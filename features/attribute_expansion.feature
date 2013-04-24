Feature: Expand EL Attribute References
    As a CloudFormation user
    I want to use an expression language as a shorthand for references
    So that I my templates are easier to read

    Scenario: Attribute expansion
        Given I have a file "outputs.yml" containing
        """
        EntryPoint:
            Description: IP address of the Bastion Host
            Value: $(BastionHost.PublicIp)
        """
        When I process "outputs.yml"
        Then the output should match JSON
        """
        {
            "AWSTemplateFormatVersion" : "2010-09-09",
            "EntryPoint" : {
                "Description" : "IP address of the Bastion Host",
                "Value" :  { "Fn::GetAtt" : [ "BastionHost", "PublicIp" ]}
            }
        }
        """

    Scenario: Embedded attribute expansion
        Given I have a file "outputs.yml" containing
        """
        WebSite:
            Description: URL of the website
            Value: http://$(PublicElasticLoadBalancer.DNSName)/index.html
        """
        When I process "outputs.yml"
        Then the output should match JSON
        """
        {
            "AWSTemplateFormatVersion" : "2010-09-09",
            "WebSite" : {                                                                                                                                            
                "Description" : "URL of the website",
                "Value" :  { "Fn::Join" : [ "", [ "http://", { "Fn::GetAtt" : [ "PublicElasticLoadBalancer", "DNSName" ]}, "/index.html"]]}
            }
        }
        """

