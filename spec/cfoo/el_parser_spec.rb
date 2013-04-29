require 'spec_helper'

module Cfoo
    describe ExpressionLanguage do
        let(:parser) { ExpressionLanguage }
        it 'turns simple EL references into CloudFormation "Ref" maps' do
            parser.parse("$(orange)").should == [{"Ref" => "orange"}]
        end

        it 'turns EL references embedded in strings into appended arrays' do
            parser.parse("large $(MelonType) melon").should == [ "large ", { "Ref" => "MelonType" }, " melon" ]
        end

        it 'turns multiple EL references embedded in strings into single appended arrays' do
            parser.parse("I have $(number) apples and $(otherNumber) oranges").should == ["I have ", { "Ref" => "number" }, " apples and ", { "Ref" => "otherNumber" }, " oranges" ]
        end

        it 'turns EL attribute references into CloudFormation "GetAtt" maps' do
            parser.parse("$(apple.color)").should == [{"Fn::GetAtt" => ["apple", "color"]}]
        end

        it 'turns EL attribute map references into CloudFormation "GetAtt" maps' do
            parser.parse("$(apple[color])").should == [{"Fn::GetAtt" => ["apple", "color"]}]
        end

        it 'turns EL map references into CloudFormation "FindInMap" maps' do
            parser.parse("$(fruit[apple][color])").should == [{"Fn::FindInMap" => ["fruit", "apple", "color"]}]
        end

        it "doesn't expand escaped EL" do
            parser.parse("\\$(apple.color) apple").should == ["$" , "(apple.color) apple"]
        end

        it "copes with lone backslashes" do
            parser.parse("\\ apple").should == ["\\" , " apple"]
        end

        it "copes with EL in maps" do
            parser.parse("$(fruit[$(fruitType)][$(fruitProperty)])").should == [{"Fn::FindInMap" => ["fruit", {"Ref" => "fruitType"}, {"Ref" => "fruitProperty"}]}]
        end

        it "copes with EL in references" do
            parser.parse("$($(appleProperty))").should == [{"Ref" => {"Ref" => "appleProperty"}}]
        end
    end
end

