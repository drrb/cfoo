require 'spec_helper'

module Cfoo
    describe Cfoo do
        let(:processor) { double('processor') }
        let(:renderer) { double('renderer') }
        let(:stdout) { double('stdout') }
        let(:stderr) { double('stderr') }
        let(:cfoo) { Cfoo.new(processor, renderer, stdout, stderr) }

        describe "#process" do
            it "processes the specified files" do
                output_map = double("output_map")
                processor.should_receive(:process).with("1.yml", "2.yml").and_return output_map
                renderer.should_receive(:render).with(output_map).and_return "cfn_template"
                stdout.should_receive(:puts).with "cfn_template"
                cfoo.process("1.yml", "2.yml")
            end

            context "when an error is raised" do
                it "prints it to stderr" do
                    error = RuntimeError.new("parse fail")
                    processor.should_receive(:process).with("1.yml").and_raise error
                    stderr.should_receive(:puts).with error
                    cfoo.process("1.yml")
                end
            end
        end

        describe "#build_project" do
            # TODO: but it doesn't know about the project!
            it "processes all files in the project" do
                output_map = double("output_map")
                processor.should_receive(:process_all).and_return output_map
                renderer.should_receive(:render).with(output_map).and_return "cfn_template"
                stdout.should_receive(:puts).with "cfn_template"
                cfoo.build_project
            end

            context "when an error is raised" do
                it "prints it to stderr" do
                    error = RuntimeError.new("parse fail")
                    processor.should_receive(:process_all).and_raise error
                    stderr.should_receive(:puts).with error
                    cfoo.build_project
                end
            end
        end
    end
end
