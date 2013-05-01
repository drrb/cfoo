require 'spec_helper'
require 'fileutils'
include FileUtils

module Cfoo
    describe FileSystem do
        let(:project_root) { "/tmp/#{File.basename(__FILE__)}#{$$}" }
        let(:file_system) { FileSystem.new(project_root) }
        before do
            rm_rf project_root
            mkdir project_root
        end

        after do
            rm_rf project_root
        end

        describe "#list" do
            it "returns full path of files, resolved relative to project root" do
                files = %w[a b c].map {|file| File.join(project_root, "modules", file) }
                mkdir File.join(project_root, "modules")
                touch files 

                file_system.list("modules").sort.should == files
            end
        end

        describe "#glob_relative" do
            it "returns relative path of files, resolved relative to project root" do
                files = %w[a b c].map {|file| File.join(project_root, "modules", file) }
                mkdir File.join(project_root, "modules")
                touch files 

                relative_files = files.map {|f| f.gsub(project_root + "/", "")}

                file_system.glob_relative("modules/*").sort.should == relative_files
            end
            it "expands globs" do
                files = %w[a.txt b.json c.yml].map {|file| File.join(project_root, "modules", file) }
                mkdir File.join(project_root, "modules")
                touch files 

                file_system.glob_relative("modules/*.yml").should == ["modules/c.yml"]
            end
        end
        describe "#parse_file" do
            it "parses a file as YAML" do
                write "#{project_root}/file.yml", "key: value"

                file_system.parse_file("file.yml").should == {"key" => "value"}
            end
            context "when the YAML contains EL" do
                it "parses it with the EL intact" do
                    write "#{project_root}/el.yml", "key: [$(value)]"

                    file_system.parse_file("el.yml").should == {"key" => ["$(value)"]}
                end
            end
            context "when the YAML is invalid" do
                it "raises an error" do
                    write "#{project_root}/bad.yml", "key: : value"

                    expect {file_system.parse_file("bad.yml")}.to raise_error
                end
            end
            context "when the YAML contains a custom AWS datatype" do
                it "wraps references in AWS Ref maps" do
                    write "#{project_root}/ref.yml", "!Ref AWS::Region"

                    file_system.parse_file("ref.yml").should == YAML::DomainType.create("Ref", "AWS::Region")
                end
                it "wraps attribute references in AWS GetAtt maps" do
                    write "#{project_root}/getatt.yml", "!GetAtt [Object, Property]"

                    file_system.parse_file("getatt.yml").should == YAML::DomainType.create("GetAtt", ["Object", "Property"])
                end
                it "wraps joins in AWS Join function-calls" do
                    write "#{project_root}/join.yml", "!Join ['', [a, b, c]]"

                    file_system.parse_file("join.yml").should == YAML::DomainType.create("Join", ["", ["a","b","c"]])
                end
                it "wraps concatenations in AWS Join function-calls with empty strings" do
                    write "#{project_root}/concat.yml", "!Concat [a, b, c]"

                    file_system.parse_file("concat.yml").should == YAML::DomainType.create("Concat", ["a","b","c"])
                end
                it "wraps map lookups in AWS FindInMap function-calls" do
                    write "#{project_root}/findinmap.yml", "!FindInMap [Map, Key, Value]"

                    file_system.parse_file("findinmap.yml").should == YAML::DomainType.create("FindInMap", ["Map", "Key", "Value"])
                end
                it "wraps base64 strings in AWS Base64 function-calls" do
                    write "#{project_root}/base64.yml", "!Base64 myencodedstring"

                    file_system.parse_file("base64.yml").should == YAML::DomainType.create("Base64", "myencodedstring")
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
