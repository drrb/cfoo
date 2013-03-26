require 'spec_helper'

module Cfoo
    describe Parser do
        let(:file_system) { double('file_system') }
        let(:parser) { Parser.new(file_system) }

        describe "#parse_file" do
            context "when processing a normal array" do
                it "returns it" do
                    file_system.should_receive(:parse_file).with("myfile.yml").and_return([1, 2, 3])
                    parser.parse_file("myfile.yml").should == [1, 2, 3]
                end
            end
            context "when processing a normal map" do
                it "returns it" do
                    file_system.should_receive(:parse_file).with("myfile.yml").and_return({"a" => "b"})
                    parser.parse_file("myfile.yml").should == { "a" => "b" }
                end
            end

            context "when parsing boolean literals" do
                it "turns them into strings" do
                    #file_system.should_receive(:parse_file).with("myfile.yml").and_return(false)
                    #parser.parse_file("myfile.yml").should == "false"
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
                        file_system.should_receive(:parse_file).with("myfile.yml").and_return(input_array)
                    end

                    it 'turns simple references into CloudFormation "Ref" maps' do
                        parser.parse_file("myfile.yml")[1].should == {"Ref" => "orange"}
                    end

                    it 'turns references embedded in strings into appended arrays' do
                        parser.parse_file("myfile.yml")[2].should == {"Fn::Join" => [ "", [ "large ", { "Ref" => "MelonType" }, " melon" ] ] }
                    end

                    it 'turns multiple references embedded in strings into single appended arrays' do
                        expected = {"Fn::Join" => [ "", [ { "Ref" => "apples" }, " and ", { "Ref" => "oranges" } ] ] }
                        parser.parse_file("myfile.yml")[3].should == expected
                    end

                    it 'turns attribute references into CloudFormation "GetAtt" maps' do
                        parser.parse_file("myfile.yml")[4].should == {"Fn::GetAtt" => ["apple", "color"]}
                    end
                end

                context "in a map" do
                    let(:input_map) { { "IpAddress" => "$(IpAddress)", "Website URL" => "http://$(Hostname)/index.html" } }
                    before do
                        file_system.should_receive(:parse_file).with("myfile.yml").and_return(input_map)
                    end

                    it 'turns simple references into CloudFormation "Ref" maps' do
                        parser.parse_file("myfile.yml")["IpAddress"].should == {"Ref" => "IpAddress"}
                    end

                    it 'turns references embedded in strings into appended arrays' do
                        parser.parse_file("myfile.yml")["Website URL"].should == {"Fn::Join" => [ "", [ "http://", { "Ref" => "Hostname" }, "/index.html" ] ] }
                    end
                end

                context "in a complex data structure" do
                    let(:input_map) { { "AvailabilityZones" => ["$(PublicSubnetAz)"], "URLs" => ["http://$(Hostname)/index.html"] } }
                    before do
                        file_system.should_receive(:parse_file).with("myfile.yml").and_return(input_map)
                    end

                    it 'turns simple references into CloudFormation "Ref" maps' do
                        parser.parse_file("myfile.yml")["AvailabilityZones"][0].should == {"Ref" => "PublicSubnetAz"}
                    end

                    it 'turns references embedded in strings into appended arrays' do
                        parser.parse_file("myfile.yml")["URLs"][0].should == {"Fn::Join" => [ "", [ "http://", { "Ref" => "Hostname" }, "/index.html" ] ] }
                    end
                end
            end
        end
    end
end
