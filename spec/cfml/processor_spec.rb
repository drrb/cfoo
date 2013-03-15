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
            context "when presented with simple EL references in an array" do
                it 'turns them into CloudFormation "Ref" maps' do
                    input_array = [ "one", "${two}", "three" ]
                    processed_array = [ "one", {"Ref" => "two"}, "three" ]
                    project.should_receive(:parse_file).with("myfile.yml").and_return(input_array)
                    processor.process("myfile.yml").should == processed_array
                end
            end
        end
    end
end

