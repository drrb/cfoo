require 'spec_helper'

module Cfoo
    describe Project do

        let(:file_system) { double('file_system') }
        let(:project) { Project.new(file_system) }
        describe '#modules' do
            it 'lists the directories in the "modules" folder of the project' do
                file_system.should_receive(:list_relative).with("modules").and_return ["a", "b", "c"]
                project.modules.should == ["a", "b", "c"].map {|e| Module.new("modules/#{e}", file_system) }
            end
        end
    end
end

