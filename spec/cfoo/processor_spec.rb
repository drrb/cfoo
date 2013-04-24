require 'spec_helper'

module Cfoo
    describe Processor do

        let(:parser) { double('parser') }
        let(:project) { double('project') }
        let(:processor) { Processor.new(parser, project) }

        describe "#process" do
            it "parses the specified files" do
                parser.should_receive(:parse_file).with("app.yml").and_return({"Resources" => { "AppServer" => { "Type" => "EC2Instance" } } })
                parser.should_receive(:parse_file).with("db.yml").and_return({"Resources" => { "DbServer" => { "Type" => "EC2Instance" } } })
                parser.should_receive(:parse_file).with("network.yml").and_return({"Parameters" => { "LoadBalancerIpAddress" => "10.0.0.51" } })
                processor.process("app.yml", "db.yml", "network.yml").should == {
                    "AWSTemplateFormatVersion" => "2010-09-09",
                    "Parameters" => {
                        "LoadBalancerIpAddress" => "10.0.0.51"
                    },
                    "Resources" => {
                        "AppServer" => { "Type" => "EC2Instance" },
                        "DbServer" => { "Type" => "EC2Instance" }
                    }
                }
            end
        end

        describe "#process_all" do
            it "processes all modules" do
                modules = [ double("module0"), double("module1") ]
                project.should_receive(:modules).and_return(modules)
                modules[0].should_receive(:files).and_return ["app.yml", "db.yml"]
                modules[1].should_receive(:files).and_return ["network.yml"]
                parser.should_receive(:parse_file).with("app.yml").and_return({"Resources" => { "AppServer" => { "Type" => "EC2Instance" } } })
                parser.should_receive(:parse_file).with("db.yml").and_return({"Resources" => { "DbServer" => { "Type" => "EC2Instance" } } })
                parser.should_receive(:parse_file).with("network.yml").and_return({"Parameters" => { "LoadBalancerIpAddress" => "10.0.0.51" } })

                processor.process_all.should == {
                    "AWSTemplateFormatVersion" => "2010-09-09",
                    "Parameters" => {
                        "LoadBalancerIpAddress" => "10.0.0.51"
                    },
                    "Resources" => {
                        "AppServer" => { "Type" => "EC2Instance" },
                        "DbServer" => { "Type" => "EC2Instance" }
                    }
                }
            end
        end
    end
end

