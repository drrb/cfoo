require 'spec_helper'

describe Array do
    describe "#join_adjacent_strings" do
        context "when the array is empty" do
            it "returns an array with an empty string in it" do
                [].join_adjacent_strings.should == []
            end
        end

        context "when array has only strings" do
            it "returns an array with them all joined together" do
                ["j", "oi", "nme"].join_adjacent_strings.should == ["joinme"]
            end
        end

        context "when array has some strings and other things" do
            it "returns an array with all the adjacent strings joined together" do
                [["1"], "a", "bc", ["2", "3"], "d", " ", { "e" => "f"}, ""].join_adjacent_strings.should == [["1"], "abc", ["2", "3"], "d ", { "e"=> "f" }, ""]
            end
        end
    end
end
