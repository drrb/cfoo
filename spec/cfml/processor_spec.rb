require 'spec_helper'

module Cfml
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
                    let(:input_array) {[ "apple", "${orange}", "large ${MelonType} melon" ]}
                    before do
                        project.should_receive(:parse_file).with("myfile.yml").and_return(input_array)
                    end

                    it 'turns simple references into CloudFormation "Ref" maps' do
                        processor.process("myfile.yml")[1].should == {"Ref" => "orange"}
                    end

                    it 'turns references embedded in strings into appended arrays' do
                        processor.process("myfile.yml")[2].should == {"Fn::Join" => [ "", "large ", { "Ref" => "MelonType" }, " melon" ] }
                    end
                end

                context "in a map" do
                    let(:input_map) { { "one" => "${two}" } }
                    before do
                        project.should_receive(:parse_file).with("myfile.yml").and_return(input_map)
                    end

                    it 'turns simple references into CloudFormation "Ref" maps' do
                        processor.process("myfile.yml")["one"].should == {"Ref" => "two"}
                    end
                end

                context "in a complex data structure" do
                    let(:input_map) { { "one" => ["${two}"] } }
                    before do
                        project.should_receive(:parse_file).with("myfile.yml").and_return(input_map)
                    end

                    it 'turns simple references into CloudFormation "Ref" maps' do
                        processor.process("myfile.yml")["one"][0].should == {"Ref" => "two"}
                    end
                end
            end
        end
    end
end

