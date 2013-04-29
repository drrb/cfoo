require 'spec_helper'

module Cfoo
    describe ElParser do
        let(:parser) { ElParser.new }
        it 'turns simple EL references into CloudFormation "Ref" maps' do
            parser.parse("$(orange)").should == {"Ref" => "orange"}
        end

        it 'turns EL references embedded in strings into appended arrays' do
            parser.parse("large $(MelonType) melon").should == {"Fn::Join" => [ "", [ "large ", { "Ref" => "MelonType" }, " melon" ] ] }
        end

        it 'turns multiple EL references embedded in strings into single appended arrays' do
            parser.parse("$(apples) and $(oranges)").should == {"Fn::Join" => [ "", [ { "Ref" => "apples" }, " and ", { "Ref" => "oranges" } ] ] }
        end

        it 'turns EL attribute references into CloudFormation "GetAtt" maps' do
            parser.parse("$(apple.color)").should == {"Fn::GetAtt" => ["apple", "color"]}
        end

        it 'turns EL map references into CloudFormation "FindInMap" maps' do
            parser.parse("$(fruit[apple][color])").should == {"Fn::FindInMap" => ["fruit", "apple", "color"]}
        end

        it 'leaves escaped EL alone' do
            parser.parse("\\$(apple.color) apple").should == "$(apple.color) apple"
        end
    end
end

