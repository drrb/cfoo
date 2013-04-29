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

            context "when parsing a string" do
                it 'turns simple EL references into CloudFormation "Ref" maps' do
                    file_system.should_receive(:parse_file).with("myfile.yml").and_return("$(orange)")
                    parser.parse_file("myfile.yml").should == {"Ref" => "orange"}
                end

                it 'turns EL references embedded in strings into appended arrays' do
                    file_system.should_receive(:parse_file).with("myfile.yml").and_return("large $(MelonType) melon")
                    parser.parse_file("myfile.yml").should == {"Fn::Join" => [ "", [ "large ", { "Ref" => "MelonType" }, " melon" ] ] }
                end

                it 'turns multiple EL references embedded in strings into single appended arrays' do
                    file_system.should_receive(:parse_file).with("myfile.yml").and_return("$(apples) and $(oranges)")
                    expected = {"Fn::Join" => [ "", [ { "Ref" => "apples" }, " and ", { "Ref" => "oranges" } ] ] }
                    parser.parse_file("myfile.yml").should == expected
                end

                it 'turns EL attribute references into CloudFormation "GetAtt" maps' do
                    file_system.should_receive(:parse_file).with("myfile.yml").and_return("$(apple.color)")
                    parser.parse_file("myfile.yml").should == {"Fn::GetAtt" => ["apple", "color"]}
                end

                it 'turns EL map references into CloudFormation "FindInMap" maps' do
                    file_system.should_receive(:parse_file).with("myfile.yml").and_return("$(fruit[apple][color])")
                    parser.parse_file("myfile.yml").should == {"Fn::FindInMap" => ["fruit", "apple", "color"]}
                end

                it 'leaves escaped EL alone' do
                    file_system.should_receive(:parse_file).with("myfile.yml").and_return("\\$(apple.color) apple")
                    parser.parse_file("myfile.yml").should == "$(apple.color) apple"
                end
            end

            context "when parsing a YAML::PrivateType" do
                it "wraps references in AWS Ref maps" do
                    file_system.should_receive(:parse_file).with("ref.yml").and_return(YAML::DomainType.create("ref", "AWS::Region"))
                    parser.parse_file("ref.yml").should == {"Ref" => "AWS::Region" }
                end
                it "wraps attribute references in AWS GetAtt maps" do
                    file_system.should_receive(:parse_file).with("getattr.yml").and_return(YAML::DomainType.create("getatt", ["Object", "Property"]))

                    parser.parse_file("getattr.yml").should == {"Fn::GetAtt" => [ "Object", "Property" ] }
                end
                it "wraps joins in AWS Join function-calls" do
                    file_system.should_receive(:parse_file).with("join.yml").and_return(YAML::DomainType.create("join", ['', ["a","b","c"]]))

                    parser.parse_file("join.yml").should == {"Fn::Join" => [ "" , [ "a", "b", "c" ] ] }
                end
                it "wraps concatenations in AWS Join function-calls with empty strings" do
                    file_system.should_receive(:parse_file).with("join.yml").and_return(YAML::DomainType.create("concat", ["a","b","c"]))

                    parser.parse_file("join.yml").should == {"Fn::Join" => [ "" , [ "a", "b", "c" ] ] }
                end
                it "wraps map lookups in AWS FindInMap function-calls" do
                    file_system.should_receive(:parse_file).with("findinmap.yml").and_return(YAML::DomainType.create("findinmap", ["Map", "Key", "Value"]))

                    parser.parse_file("findinmap.yml").should == {"Fn::FindInMap" => [ "Map", "Key", "Value" ] }
                end
                it "wraps base64 strings in AWS Base64 function-calls" do
                    file_system.should_receive(:parse_file).with("b64.yml").and_return(YAML::DomainType.create("base64", "myencodedstring"))

                    parser.parse_file("b64.yml").should == {"Fn::Base64" => "myencodedstring"}
                end
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

            context "when presented with an unknown object" do
                it "raises an error" do
                    file_system.should_receive(:parse_file).with("myfile.yml").and_return(/a regex/)
                    expect {parser.parse_file("myfile.yml")}.to raise_error Parser::ElParseError
                end
            end
        end
    end
end
