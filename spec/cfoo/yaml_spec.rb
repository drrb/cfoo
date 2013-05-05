require 'spec_helper'

module YAML
   describe DomainType do
      describe "#eq?" do
         it "returns true when all properties are equal" do
            left = DomainType.create("type", "value")
            right = DomainType.create("type", "value")
            left.should == right
         end
         it "returns false when type IDs are different" do
            left = DomainType.create("type_a", "value")
            right = DomainType.create("type_b", "value")
            left.should_not == right
         end
         it "returns false when values are different" do
            left = DomainType.create("type", "value_1")
            right = DomainType.create("type", "value_2")
            left.should_not == right
         end
         it "returns false when domains are different" do
            left = DomainType.create("type", "value_1")
            right = DomainType.create("type", "value_2")
            left.should_not == right
         end
      end
   end
end

