require 'spec_helper'
require 'fileutils'
include FileUtils

module Cfoo
    describe FileSystem do
        let(:project_root) { "/tmp/#{File.basename(__FILE__)}#{$$}" }
        let(:yaml_parser) { double("yaml_parser") }
        let(:file_system) { FileSystem.new(project_root, yaml_parser) }
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

        describe "#open" do
            it "opens a file on disk for reading and passes it to the provided block" do
                write_project_file "file.txt", "test content"

                actual_content = "block not called"
                file_system.open("file.txt") do |file|
                    actual_content = file.read
                end

                actual_content.should include "test content"
            end
        end

        describe "#find_coordinates" do
            it "returns the coordinates of the first match of the specified string in the specified file" do
                write_project_file "test.txt", <<-EOF
                    the quick brown fox
                    jumps over the lazy
                    dog
                    the quick brown fox
                    jumps over the lazy
                    dog
                EOF

                row, column = file_system.find_coordinates("lazy", "test.txt")
                row.should be 2
                column.should be 36
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
            it "loads the file with the YAML parser" do
               yaml_parser.should_receive(:load_file).with("#{project_root}/yamlfile.yml")
               file_system.parse_file("yamlfile.yml")
            end
        end

        def relative(file)
            File.join(project_root, file)
        end

        def write(file, content)
            File.open(file, "w+") do |f|
                f.puts content
            end
        end

        def write_project_file(file, content)
            write(relative(file), content)
        end
    end
end
