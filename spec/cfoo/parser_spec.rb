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

            context "when parsing integer literals" do
                it "returns them" do
                    file_system.should_receive(:parse_file).with("myfile.yml").and_return(1)
                    parser.parse_file("myfile.yml").should == 1
                end
            end

            context "when parsing boolean literals" do
                it "turns false into a string" do
                    file_system.should_receive(:parse_file).with("myfile.yml").and_return(false)
                    parser.parse_file("myfile.yml").should == "false"
                end
                it "turns true into a string" do
                    file_system.should_receive(:parse_file).with("myfile.yml").and_return(true)
                    parser.parse_file("myfile.yml").should == "true"
                end
            end

            context "when parsing EL" do
                it 'turns simple references into CloudFormation "Ref" maps' do
                    file_system.should_receive(:parse_file).with("myfile.yml").and_return("$(orange)")
                    parser.parse_file("myfile.yml").should == {"Ref" => "orange"}
                end

                it 'turns references embedded in strings into appended arrays' do
                    file_system.should_receive(:parse_file).with("myfile.yml").and_return("large $(MelonType) melon")
                    parser.parse_file("myfile.yml").should == {"Fn::Join" => [ "", [ "large ", { "Ref" => "MelonType" }, " melon" ] ] }
                end

                it 'turns multiple references embedded in strings into single appended arrays' do
                    file_system.should_receive(:parse_file).with("myfile.yml").and_return("$(apples) and $(oranges)")
                    expected = {"Fn::Join" => [ "", [ { "Ref" => "apples" }, " and ", { "Ref" => "oranges" } ] ] }
                    parser.parse_file("myfile.yml").should == expected
                end

                it 'turns attribute references into CloudFormation "GetAtt" maps' do
                    file_system.should_receive(:parse_file).with("myfile.yml").and_return("$(apple.color)")
                    parser.parse_file("myfile.yml").should == {"Fn::GetAtt" => ["apple", "color"]}
                end

                context "in an array" do
                    it "expands elements' EL" do
                        file_system.should_receive(:parse_file).with("myfile.yml").and_return [ "$(orange)" ]
                        parser.parse_file("myfile.yml").should == [{"Ref" => "orange"}]
                    end
                end

                context "in a map" do
                    it "expands values' EL" do
                        file_system.should_receive(:parse_file).with("myfile.yml").and_return({ "IpAddress" => "$(IpAddress)" })
                        parser.parse_file("myfile.yml").should == {"IpAddress" => { "Ref" => "IpAddress"}}
                    end
                end

                context "in a complex data structure" do
                    it "expands EL deeply" do
                        input_map = {
                            "AvailabilityZones" => ["$(PublicSubnetAz)"],
                            "URLs" => ["http://$(Hostname)/index.html"] 
                        }
                        expected_output = {
                            "AvailabilityZones" => [ {"Ref" => "PublicSubnetAz"}],
                            "URLs" => [{"Fn::Join" => [ "", [ "http://", { "Ref" => "Hostname" }, "/index.html" ] ] }] 
                        }
                        file_system.should_receive(:parse_file).with("myfile.yml").and_return(input_map)
                        parser.parse_file("myfile.yml").should == expected_output
                    end
                end
            end
            context "when presented with an unknown object" do
                it "raises an error" do
                    file_system.should_receive(:parse_file).with("myfile.yml").and_return(/a regex/)
                    expect {parser.parse_file("myfile.yml")}.to raise_error Parser::ElParseError
                end
            end
        end
    end
end
