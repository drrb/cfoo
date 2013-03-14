require 'spec_helper'

module Cfml
    describe Processor do

        let(:project) { double('project') }
        let(:processor) { Processor.new(project) }

        describe "#process" do
            context "when processing an array" do
                it "returns it" do
                    project.should_receive(:parse_file).with("myfile.yml").and_return([1, 2, 3])
                    processor.process("myfile.yml").should == [1, 2, 3]
                end
            end
        end
    end
end

