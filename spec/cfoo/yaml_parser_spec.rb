require 'spec_helper'

module Cfoo
    describe YamlParser do

        let(:parser) { YamlParser.new }
        let(:working_dir) { "/tmp/#{File.basename(__FILE__)}#{$$}" }

        before do
            rm_rf working_dir
            mkdir working_dir
        end

        after do
            rm_rf working_dir
        end

        describe "#load_file" do
            it "parses a file as YAML" do
                write "#{working_dir}/file.yml", "key: value"

                parser.load_file("#{working_dir}/file.yml").should == {"key" => "value"}
            end
            context "when the YAML contains EL" do
                it "parses it with the EL intact" do
                    write "#{working_dir}/el.yml", "key: [$(value)]"

                    parser.load_file("#{working_dir}/el.yml").should == {"key" => ["$(value)"]}
                end
            end
            context "when the YAML is invalid" do
                it "raises an error" do
                    write "#{working_dir}/bad.yml", "key: : value"

                    expect {parser.load_file("#{working_dir}/bad.yml")}.to raise_error
                end
            end
            context "when the YAML contains a custom AWS datatype" do
                it "wraps references in AWS Ref maps" do
                    write "#{working_dir}/ref.yml", "!Ref AWS::Region"

                    parser.load_file("#{working_dir}/ref.yml").should == YAML::DomainType.create("Ref", "AWS::Region")
                end
                it "wraps attribute references in AWS GetAtt maps" do
                    write "#{working_dir}/getatt.yml", "!GetAtt [Object, Property]"

                    parser.load_file("#{working_dir}/getatt.yml").should == YAML::DomainType.create("GetAtt", ["Object", "Property"])
                end
                it "wraps joins in AWS Join function-calls" do
                    write "#{working_dir}/join.yml", "!Join ['', [a, b, c]]"

                    parser.load_file("#{working_dir}/join.yml").should == YAML::DomainType.create("Join", ["", ["a","b","c"]])
                end
                it "wraps splits in AWS Split function-calls" do
                    write "#{working_dir}/split.yml", "!Split ['|', 'a|b|c']"

                    parser.load_file("#{working_dir}/split.yml").should == YAML::DomainType.create("Split", ["|", "a|b|c"])
                end
                it "wraps imported value strings in AWS ImportValue function-calls" do
                    write "#{working_dir}/importvalue.yml", "!ImportValue exportedvaluename"

                    parser.load_file("#{working_dir}/importvalue.yml").should == YAML::DomainType.create("ImportValue", "exportedvaluename")
                end
                it "wraps selects in AWS Select function-calls" do
                    write "#{working_dir}/select.yml", "!Select [1, [a, b, c]]"

                    parser.load_file("#{working_dir}/select.yml").should == YAML::DomainType.create("Select", [1, ["a","b","c"]])
                end
                it "wraps concatenations in AWS Join function-calls with empty strings" do
                    write "#{working_dir}/concat.yml", "!Concat [a, b, c]"

                    parser.load_file("#{working_dir}/concat.yml").should == YAML::DomainType.create("Concat", ["a","b","c"])
                end
                it "wraps map lookups in AWS FindInMap function-calls" do
                    write "#{working_dir}/findinmap.yml", "!FindInMap [Map, Key, Value]"

                    parser.load_file("#{working_dir}/findinmap.yml").should == YAML::DomainType.create("FindInMap", ["Map", "Key", "Value"])
                end
                it "wraps conditions in AWS condition function-calls" do
                    write "#{working_dir}/findinmap.yml", "!Equals [a, b]"

                    parser.load_file("#{working_dir}/findinmap.yml").should == YAML::DomainType.create("Equals", ["a", "b"])
                end
                it "wraps base64 strings in AWS Base64 function-calls" do
                    write "#{working_dir}/base64.yml", "!Base64 myencodedstring"

                    parser.load_file("#{working_dir}/base64.yml").should == YAML::DomainType.create("Base64", "myencodedstring")
                end
                it "converts AZ lookups to GetAZs function-calls" do
                    write "#{working_dir}/get_azs.yml", "!GetAZs myregion"

                    parser.load_file("#{working_dir}/get_azs.yml").should == YAML::DomainType.create("GetAZs", "myregion")
                end
                it "converts empty AZ lookups to GetAZs function-calls" do
                    write "#{working_dir}/get_azs_empty.yml", "!GetAZs ''"

                    value = YAML.name == "Psych" ? nil : ""
                    parser.load_file("#{working_dir}/get_azs_empty.yml").should == YAML::DomainType.create("GetAZs", value)
                end
            end
        end

        def write(file, content)
            File.open(file, "w+") do |f|
                f.puts content
            end
        end
    end
end

