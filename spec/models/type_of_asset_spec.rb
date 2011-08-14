require 'spec_helper'

describe TypeOfAsset do
  context "should not be created if" do
    it "name is blank" do
      toa = TypeOfAsset.spawn(:name => "", :conversion => 1)
      toa.should_not be_valid
      toa.should have(1).error_on(:name)
      assert_raises ActiveRecord::RecordInvalid do
        toa.save!
      end
    end

    it "name is nil" do
      toa = TypeOfAsset.spawn(:name => nil, :conversion => 1)
      toa.should_not be_valid
      toa.should have(1).error_on(:name)
      assert_raises ActiveRecord::RecordInvalid do
        toa.save!
      end
    end

    it "conversion is nil" do
      toa = TypeOfAsset.spawn(:name => "test", :conversion => nil)
      toa.should_not be_valid
      toa.should have(1).error_on(:conversion)
      assert_raises ActiveRecord::RecordInvalid do
        toa.save!
      end
    end
  end

  context "should be created if" do
    it "all attributes correct" do
      toa = TypeOfAsset.spawn(:name => "test", :conversion => 1)
      assert_nothing_raised do
        toa.save!
      end
      toa.should be_valid
    end
  end
end
