require 'spec_helper'

module Cfoo
    describe Factory do
        let(:stdout) { double('stderr') }
        let(:stderr) { double('stderr') }
        let(:factory) { Factory.new(stdout, stderr) }

        describe "#cfoo" do
            it "builds a Cfoo instance with its dependencies" do
                cfoo = factory.cfoo
                cfoo.class.should be Cfoo

                cfoo.instance_eval{ @stdout }.should be stdout
                cfoo.instance_eval{ @stderr }.should be stderr
                cfoo.instance_eval{ @processor }.class.should be Processor
                cfoo.instance_eval{ @renderer }.class.should be Renderer
            end
        end

    end
end
