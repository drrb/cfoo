Feature: Expand EL References
    As a CloudFormation user
    I want to use an expression language as a shorthand for references
    So that I my templates are easier to read

    Scenario: Simple reference
        Given I have a file "reference.yml" containing
        """
        Server:
            InstanceType: $(InstanceType)
            SecurityGroups:
                - sg-123456
                - $(SshSecurityGroup)
                - sg-987654
        """
        When I process "reference.yml"
        Then the output should match JSON
        """
        {
            "Server" : {
                "InstanceType" : { "Ref" : "InstanceType" },
                "SecurityGroups" : [
                    "sg-123456",
                    { "Ref": "SshSecurityGroup" },
                    "sg-987654"
                ]
            }
        }
        """

    Scenario: Embedded reference
        Given I have a file "reference.yml" containing
        """
        content:
            /var/www/html: http://$(DownloadHost)/website.tar.gz
            /etc/puppet: https://github.com/$(GithubAccount)/$(RepoName).git
        """
        When I process "reference.yml"
        Then the output should match JSON
        """
        {
            "content": {
                "/var/www/html" : { "Fn::Join" : [ "", [ "http://", {"Ref" : "DownloadHost"}, "/website.tar.gz" ] ] },
                "/etc/puppet" : { "Fn::Join" : [ "", [ "https://github.com/", {"Ref" : "GithubAccount"}, "/", {"Ref" : "RepoName"}, ".git" ] ] }
            }
        }
        """
