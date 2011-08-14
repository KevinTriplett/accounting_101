require 'spec_helper'

describe TypeOfAccount do
  context "should not be created if" do
    it "name is blank" do
      toa = TypeOfAccount.spawn(:name => "")
      toa.should_not be_valid
      toa.should have(1).error_on(:name)
      assert_raises ActiveRecord::RecordInvalid do
        toa.save!
      end
    end

    it "name is nil" do
      toa = TypeOfAccount.spawn(:name => nil)
      toa.should_not be_valid
      toa.should have(1).error_on(:name)
      assert_raises ActiveRecord::RecordInvalid do
        toa.save!
      end
    end
  end

  context "should be created if" do
    it "all attributes correct" do
      toa = TypeOfAccount.spawn(:name => "test")
      assert_nothing_raised do
        toa.save!
      end
      toa.should be_valid
    end
  end
end
