require 'spec_helper'

module Cfoo
    describe Module do
        let(:file_system) { double('file_system') }
        let(:mod) { Module.new("/modulepath", file_system) }

        describe "#files" do
            it "lists all files in the module directory" do
                files = ["file1.yml", "file2.yml", "file3.yml"]
                file_system.should_receive(:glob_relative).with("/modulepath/*.yml").and_return files
                mod.files.should == files
            end
        end
    end
end
