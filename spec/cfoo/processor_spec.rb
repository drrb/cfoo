require 'spec_helper'

module Cfoo
    describe Processor do

        let(:project) { double('project') }
        let(:processor) { Processor.new(project) }

        describe "#process" do
            context "when processing a normal array" do
                it "returns it" do
                    project.should_receive(:parse_file).with("myfile.yml").and_return([1, 2, 3])
                    processor.process("myfile.yml").should == [1, 2, 3]
                end
            end
            context "when processing a normal map" do
                it "returns it" do
                    project.should_receive(:parse_file).with("myfile.yml").and_return({"a" => "b"})
                    processor.process("myfile.yml").should == { "a" => "b" }
                end
            end
            context "when presented with EL" do
                context "in an array" do
                    let(:input_array) {[
                        "apple",
                        "$(orange)",
                        "large $(MelonType) melon",
                        "$(apples) and $(oranges)",
                        "$(apple.color)"
                    ]}
                    before do
                        project.should_receive(:parse_file).with("myfile.yml").and_return(input_array)
                    end

                    it 'turns simple references into CloudFormation "Ref" maps' do
                        processor.process("myfile.yml")[1].should == {"Ref" => "orange"}
                    end

                    it 'turns references embedded in strings into appended arrays' do
                        processor.process("myfile.yml")[2].should == {"Fn::Join" => [ "", [ "large ", { "Ref" => "MelonType" }, " melon" ] ] }
                    end

                    it 'turns multiple references embedded in strings into single appended arrays' do
                        expected = {"Fn::Join" => [ "", [ { "Ref" => "apples" }, " and ", { "Ref" => "oranges" } ] ] }
                        processor.process("myfile.yml")[3].should == expected
                    end

                    it 'turns attribute references into CloudFormation "GetAtt" maps' do
                        processor.process("myfile.yml")[4].should == {"Fn::GetAtt" => ["apple", "color"]}
                    end
                end

                context "in a map" do
                    let(:input_map) { { "IpAddress" => "$(IpAddress)", "Website URL" => "http://$(Hostname)/index.html" } }
                    before do
                        project.should_receive(:parse_file).with("myfile.yml").and_return(input_map)
                    end

                    it 'turns simple references into CloudFormation "Ref" maps' do
                        processor.process("myfile.yml")["IpAddress"].should == {"Ref" => "IpAddress"}
                    end

                    it 'turns references embedded in strings into appended arrays' do
                        processor.process("myfile.yml")["Website URL"].should == {"Fn::Join" => [ "", [ "http://", { "Ref" => "Hostname" }, "/index.html" ] ] }
                    end
                end

                context "in a complex data structure" do
                    let(:input_map) { { "AvailabilityZones" => ["$(PublicSubnetAz)"], "URLs" => ["http://$(Hostname)/index.html"] } }
                    before do
                        project.should_receive(:parse_file).with("myfile.yml").and_return(input_map)
                    end

                    it 'turns simple references into CloudFormation "Ref" maps' do
                        processor.process("myfile.yml")["AvailabilityZones"][0].should == {"Ref" => "PublicSubnetAz"}
                    end

                    it 'turns references embedded in strings into appended arrays' do
                        processor.process("myfile.yml")["URLs"][0].should == {"Fn::Join" => [ "", [ "http://", { "Ref" => "Hostname" }, "/index.html" ] ] }
                    end
                end
            end
        end

        describe "#process_all" do
            it "processes all modules" do
                modules = [ double("module0"), double("module1") ]
                project.should_receive(:modules).and_return(modules)
                modules[0].should_receive(:files).and_return ["app.yml", "db.yml"]
                modules[1].should_receive(:files).and_return ["network.yml"]
                project.should_receive(:parse_file).with("app.yml").and_return({"Resources" => { "AppServer" => { "Type" => "EC2Instance" } } })
                project.should_receive(:parse_file).with("db.yml").and_return({"Resources" => { "DbServer" => { "Type" => "EC2Instance" } } })
                project.should_receive(:parse_file).with("network.yml").and_return({"Parameters" => { "LoadBalancerIpAddress" => "10.0.0.51" } })

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

