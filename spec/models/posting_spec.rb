require 'spec_helper'

describe Posting do
  context "should not be created if" do
    it "amount is blank" do
      posting = Posting.spawn(:amount => nil)
      posting.should_not be_valid
      posting.should have(1).error_on(:amount)
      assert_raises ActiveRecord::RecordInvalid do
        posting.save!
      end
    end
  end               

  context "should be created if" do
    it "type_of_asset blank" do
      posting = Posting.spawn(:type_of_asset => nil)
      posting.should be_valid
      assert_nothing_raised do
        posting.save!
      end
    end

    it "all attributes correct" do
      assert_nothing_raised do
        Posting.generate!
      end
    end
  end

  context "conversion" do
    before(:each) do
      @toa = TypeOfAsset.create!(:name => "widget", :conversion => 2.23)
      @posting = Posting.spawn(:type_of_asset_id => @toa.id)
    end

    it "should default to 1" do
      Posting.new.conversion.should == 1
    end

    it "should convert amount" do
      @posting.amount = 4.24
      @posting.save!
      @posting.amount.should == 9.46 # amount returns (2.23 * 4.24).round(2)
    end

    it "should not change if source changes" do
      @posting.save!
      @toa.conversion = 3.12
      @toa.save!
      @posting.conversion.should == 2.23
    end

    it "should not change if source changes, even on reload" do
      @posting.save!
      @toa.conversion = 3.12
      @toa.save!
      @posting.reload.conversion.should == 2.23
    end
  end

  context ":amount validation" do
    it "should not allow zero" do
      posting = Posting.spawn(:amount => 0.00)
      posting.should_not be_valid
      assert_raises ActiveRecord::RecordInvalid do
        posting.save!
      end
    end

    it "allow negative amounts" do
      posting = Posting.spawn(:amount => -0.01)
      posting.should be_valid
      assert_nothing_raised do
        posting.save!
      end
    end

    it "allow positive amounts" do
      posting = Posting.spawn(:amount => 0.01)
      posting.should be_valid
      assert_nothing_raised do
        posting.save!
      end
    end
  end

  context "#create" do
    it "should default transacted_on if not provided" do
      posting = Posting.spawn(:transacted_on => nil)
      posting.save!
      assert_equal Date.parse(posting.created_at.to_s), Date.parse(posting.transacted_on.to_s)
    end

    it "should not default transacted_on if provided" do
      t_on = Time.now + 3.days
      posting = Posting.spawn(:transacted_on => t_on)
      posting.save!
      assert_equal Date.parse(t_on.to_s), Date.parse(posting.transacted_on.to_s)
    end

    it "should default conversion if type of asset not provided" do
      posting = Posting.spawn(:type_of_asset_id => nil)
      posting.save!
      posting.conversion.should == 1.00
    end

    it "should not default conversion if type of asset provided" do
      con = 3.42
      toa = TypeOfAsset.create!(:name => "widget", :conversion => con)
      posting = Posting.spawn(:type_of_asset_id => toa.id)
      posting.save!
      posting.conversion.should == con
    end

  end

  context "#account_name" do
    it "return name of account" do
      account = Account.generate!(:name => "account 1")
      posting = Posting.spawn
      account.postings << posting
      account.save!
      assert_equal account.name, posting.account_name
    end
  end

  context "state " do
    it "should change from cleared to reconciled" do
       posting = Posting.spawn(:amount => 1.00, :memo => "test", :state => "cleared")
       posting.reconcile!
       posting.state.should == "reconciled"
    end
    it "should change from cleared to uncleared" do
       posting = Posting.spawn(:amount => 1.00, :memo => "test", :state => "cleared")
       posting.unclear!
       posting.state.should == "uncleared"
    end
    it "should change from uncleared to cleared " do
      posting = Posting.spawn(:amount => 1.00, :memo => "test", :state => "uncleared")
      posting.clear!
      posting.state.should == "cleared"
    end
    it "should change from reconciled to uncleared" do
      posting = Posting.spawn(:amount => 1.00, :memo => "test", :state => "reconciled")
      posting.unclear!
      posting.state.should != "uncleared"
    end
    it "should not change from reconciled to cleared " do
      posting = Posting.spawn(:amount => 1.00, :memo => "test", :state => "reconciled")
      assert_raises {posting.clear!}
      posting.state.should  == "reconciled"
    end
    it "should not change from uncleared to reconciled " do
      posting = Posting.spawn(:amount => 1.00, :memo => "test", :state => "uncleared")
      assert_raises {posting.reconcile!}
      posting.state.should == "uncleared"
    end
  end
end
