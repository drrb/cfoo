require 'spec_helper'

module Cfoo
    describe Renderer do
        describe "#render" do
            let(:renderer) { Renderer.new }
            it "renders a Hash as a CloudFormation JSON template" do
                hash = {
                    "Resources" => {
                            "Server" => { "Type" => "EC2Instance" },
                            "DNS Entry" => { "Type" => "ARecord" }
                        }
                }
                renderer.render(hash).should == JSON.pretty_unparse(hash)
            end
        end
    end
end

