require 'spec_helper'

module Cfoo
    describe ElParser do
        let(:parser) { ElParser }
        it 'turns simple EL references into CloudFormation "Ref" maps' do
            parser.parse("$(orange)").should == {"Ref" => "orange"}
        end

        it 'turns EL references embedded in strings into appended arrays' do
            parser.parse("large $(MelonType) melon").should == {"Fn::Join" => [ "" , [ "large ", { "Ref" => "MelonType" }, " melon" ]]}
        end

        it 'turns multiple EL references embedded in strings into single appended arrays' do
            parser.parse("I have $(number) apples and $(otherNumber) oranges").should == {"Fn::Join" => [ "" , ["I have ", { "Ref" => "number" }, " apples and ", { "Ref" => "otherNumber" }, " oranges" ]]}
        end

        it 'turns EL attribute references into CloudFormation "GetAtt" maps' do
            parser.parse("$(apple.color)").should == {"Fn::GetAtt" => ["apple", "color"]}
        end

        it 'turns EL attribute map references into CloudFormation "GetAtt" maps' do
            parser.parse("$(apple[color])").should == {"Fn::GetAtt" => ["apple", "color"]}
        end

        it 'turns EL map references into CloudFormation "FindInMap" maps' do
            parser.parse("$(fruit[apple][color])").should == {"Fn::FindInMap" => ["fruit", "apple", "color"]}
        end

        context "parsing function calls" do
            it 'turns no-arg function calls into "Fn" maps with an empty string as the value' do
                parser.parse("$(Fruit())").should == {"Fn::Fruit" => ""}
            end

            it 'turns single-arg function calls into "Fn" maps with the string as the value' do
                parser.parse("$(Fruit(Favorite))").should == {"Fn::Fruit" => "Favorite"}
            end

            it 'turns multi-arg function calls into "Fn" maps with the an array of the arg strings as the value' do
                parser.parse("$(Fruit(One, Two, Three))").should == {"Fn::Fruit" => [ "One", "Two", "Three" ]}
            end

            it 'copes with no spaces between function arguments' do
                parser.parse("$(Fruit(One,Two,Three))").should == {"Fn::Fruit" => [ "One", "Two", "Three" ]}
            end

            it 'copes with spaces between around function arguments' do
                parser.parse("$(Fruit(  One   , Two ,Three   ))").should == {"Fn::Fruit" => [ "One", "Two", "Three" ]}
            end

            it 'copes with EL as arguments' do
                parser.parse("$(FindInMap(AWSRegionArch2AMI, $(AWS::Region), $(AWSInstanceType2Arch[FrontendInstanceType][Arch])))").
                    should == {"Fn::FindInMap" => ["AWSRegionArch2AMI", {"Ref" => "AWS::Region"}, { "Fn::FindInMap" => ["AWSInstanceType2Arch", "FrontendInstanceType", "Arch"] }]}
            end
        end

        it "doesn't expand escaped EL" do
            parser.parse("\\$(apple.color) apple").should == "$(apple.color) apple"
        end

        it "copes with lone backslashes" do
            parser.parse("\\ apple").should == "\\ apple"
        end

        it "copes with EL in maps" do
            parser.parse("$(Fruit[$(AWS::FruitType)][$(FruitProperty)])").should == {"Fn::FindInMap" => ["Fruit", {"Ref" => "AWS::FruitType"}, {"Ref" => "FruitProperty"}]}
        end

        it "copes with EL in references" do
            parser.parse("$($(appleProperty))").should == {"Ref" => {"Ref" => "appleProperty"}}
        end

        it "handles letters, numbers, underscores, and colons in identifiers" do
            parser.parse("$(AWS::Hip_2_the_groove_identifier)").should == {"Ref" => "AWS::Hip_2_the_groove_identifier"}
        end
    end
end

