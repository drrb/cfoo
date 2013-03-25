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

                file_system.list("modules").should == files
            end
        end

        describe "#glob_relative" do
            it "returns relative path of files, resolved relative to project root" do
                files = %w[a b c].map {|file| File.join(project_root, "modules", file) }
                mkdir File.join(project_root, "modules")
                touch files 

                relative_files = files.map {|f| f.gsub(project_root + "/", "")}

                file_system.glob_relative("modules/*").should == relative_files
            end
            it "expands globs" do
                files = %w[a.txt b.json c.yml].map {|file| File.join(project_root, "modules", file) }
                mkdir File.join(project_root, "modules")
                touch files 

                file_system.glob_relative("modules/*.yml").should == ["modules/c.yml"]
            end
        end
    end
end
