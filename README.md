# Cfoo

[![Build Status](https://travis-ci.org/drrb/cfoo.png?branch=master)](https://travis-ci.org/drrb/cfoo)
[![Coverage Status](https://coveralls.io/repos/drrb/cfoo/badge.png?branch=master)](https://coveralls.io/r/drrb/cfoo)
[![Code Climate](https://codeclimate.com/github/drrb/cfoo.png)](https://codeclimate.com/github/drrb/cfoo)

[![Gem Version](https://badge.fury.io/rb/cfoo.png)](https://badge.fury.io/rb/cfoo)
[![Dependency Status](https://gemnasium.com/drrb/cfoo.png)](https://gemnasium.com/drrb/cfoo)

Write your CloudFormation templates in a YAML-based markup language

## Installation

Cfoo can be installed as a Ruby Gem

    $ gem install cfoo

## Usage

1. Write your CloudFormation templates using Cfoo YAML 

2. Turn your Cfoo templates into normal CloudFormation templates
```terminal
$ cfoo web-server-template.yml database-template.yml > web-stack.template.json`
```

3. Create your stack with CloudFormation
```terminal
$ cfn-create-stack --stack-name WebStack -f web-stack.template.json`
```

## Templates

### Comparison with standard CloudFormation templates

Snippet from a CloudFormation template (based on [this example](https://s3.amazonaws.com/cloudformation-templates-us-east-1/Rails_Single_Instance.template)):

```json
"Properties": {
  "ImageId" : { "Fn::FindInMap" : [ "AWSRegion2AMI", { "Ref" : "AWS::Region" }, "AMI" ] },
  "InstanceType"   : { "Ref" : "InstanceType" },
  "SecurityGroups" : [ {"Ref" : "FrontendGroup"} ],
  "KeyName"        : { "Ref" : "KeyName" },
  "UserData"       : { "Fn::Base64" : { "Fn::Join" : ["", [
    "#!/bin/bash -v\n",
    "yum update -y aws-cfn-bootstrap\n",

    "function error_exit\n",
    "{\n",
    "  /opt/aws/bin/cfn-signal -e 1 -r \"$1\" '", { "Ref" : "WaitHandle" }, "'\n",
    "  exit 1\n",
    "}\n",

    "/opt/aws/bin/cfn-init -s ", { "Ref" : "AWS::StackId" }, " -r WebServer ",
    "    --region ", { "Ref" : "AWS::Region" }, " || error_exit 'Failed to run cfn-init'\n",

    "/opt/aws/bin/cfn-signal -e 0 -r \"cfn-init complete\" '", { "Ref" : "WaitHandle" }, "'\n"
  ]]}}        
}
```

Equivalent Cfoo template snippet:

```yaml
Properties:
  ImageId : AWSRegion2AMI[$(AWS::Region)][AMI]
  InstanceType: $(InstanceType)
  SecurityGroups: 
     - $(FrontendGroup)
  KeyName: $(KeyName)
  UserData: !Base64 |
    #!/bin/bash -v
    yum update -y aws-cfn-bootstrap

    function error_exit
    {
      /opt/aws/bin/cfn-signal -e 1 -r "$1" '$(WaitHandle)'
      exit 1
    }

    /opt/aws/bin/cfn-init -s $(AWS::StackId) -r WebServer --region $(AWS::Region) || error_exit 'Failed to run cfn-init'

    /opt/aws/bin/cfn-signal -e 0 -r "cfn-init completed" '$(WaitHandle)'
```

### Shortcuts

Cfoo allows you to simplify CloudFormation [intrinsic function](http://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/intrinsic-function-reference.html)
references using its own shorthand

##### Reference

CloudFormation: `{ "Ref" : "InstanceType" }`

Cfoo Shortcut: `$(InstanceType)`

##### Mapping Reference

CloudFormation: `{ "FindInMap" : [ "SubnetConfig", "VPC", "CIDR" ] }`

Cfoo Shortcut: `$(SubnetConfig[VPC][CIDR])`

##### Attribute Reference

CloudFormation: `{ "Fn::GetAtt" : [ "Ec2Instance", "PublicIp" ] }`

Cfoo Shortcut: `$(Ec2Instance.PublicIp)`

Other Shortcut: `$(Ec2Instance[PublicIp])`

##### Embedded Reference

CloudFormation: `{ "Fn::Join" : [ "", [{"Ref" : "HostedZone"}, "." ]]}`

Cfoo Shortcut: `$(HostedZone).`

### YAML Types

Cfoo gives you the option of using YAML custom data-types where it helps to make your templates easier to read.
The table below uses inline YAML lists, but multiline lists can also be used.

##### Reference

CloudFormation: `{ "Ref" : "InstanceType" }`

YAML Type: `!Ref InstanceType`

##### Mapping Reference

CloudFormation: `{ "FindInMap" : [ "SubnetConfig", "VPC", "CIDR" ] }`

YAML Type: `!FindInMap [ SubnetConfig, VPC, CIDR ]`

##### Attribute Reference

CloudFormation: `{ "Fn::GetAtt" : [ "Ec2Instance", "PublicIp" ] }`

YAML Type: `!GetAtt [ Ec2Instance, PublicIp ]`

##### Base64 String

CloudFormation: `{ "Fn::Base64" : "#!/bin/bash\necho 'Running script...'" }`

YAML Type: `!Base64 "#!/bin/bash\necho 'running script...'"`

## Goals

### Primary Goals

Cfoo aims to let developers simplify CloudFormation templates by:

- allowing them to write templates in YAML
- providing an expression language to simplify CF Ref/Attr/etc expressions
- allowing templates to be split up into logical components (to simplify and share)

### Secondary Goals

Cfoo aims (subject to Primary Goals) to:

- allow all aspects of CloudFormation templates to be expressed in YAML (so you don't need to use JSON)
- allow inclusion existing JSON templates (so you don't have to switch all at once)

### Non-goals

Cfoo does not (yet) aim to:

- provide commandline utilities for interacting directly with CloudFormation (it just generates the templates for now)
- resolve/validate references (the CloudFormation API already does this)

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Make your changes (with tests please)
4. Commit your changes (`git commit -am 'Add some feature'`)
5. Push to the branch (`git push origin my-new-feature`)
6. Create new Pull Request
