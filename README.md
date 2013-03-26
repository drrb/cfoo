# Cfoo

Write your CloudFormation templates in a YAML-based markup language

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

## Installation

Add this line to your application's Gemfile:

    gem 'cfoo'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install cfoo

## Usage

TODO: Write usage instructions here

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
