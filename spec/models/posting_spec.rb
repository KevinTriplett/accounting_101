require 'spec_helper'

def posting_attributes
  {
    :account_id => 123,
    :journal_id => 456,
    :type_of_asset_id => nil,
    :amount => 10.1
  }
end

describe Posting do
  before(:each) do
    @posting = Posting.new
  end

  context "should not be created if" do
    it "amount is blank" do
      @posting.attributes = posting_attributes.except(:amount)
      @posting.should_not be_valid
      @posting.save # save! will raise error
      @posting.should have(1).error_on(:amount)
      assert_raises ActiveRecord::RecordInvalid do
        @posting.save!
      end
    end
  end               

  context "should be created if" do
    it "type_of_asset blank" do
      @posting.attributes = posting_attributes.except(:type_of_asset_id)
      @posting.should be_valid
      assert_nothing_raised do
        @posting.save!
      end
    end
  end

  context "conversion" do
    before(:each) do
      @toa = TypeOfAsset.create!(:name => "widget", :conversion => 2.23)
      @posting.attributes = posting_attributes
    end

    it "should not change if source changes" do
      @posting.type_of_asset = @toa
      @posting.save!
      @toa.conversion = 3.12
      @toa.save!
      @posting.conversion.should == 2.23
    end

    it "should convert amount" do
      @posting.type_of_asset = @toa
      @posting.amount = 4.24
      @posting.save!
      @posting.amount.should == 9.46 # amount returns (2.23 * 4.24).round(2)
    end
  end

  context ":amount validation" do
    it "should not allow zero" do
      @posting.attributes = posting_attributes
      @posting.amount = 0.00
      @posting.should_not be_valid
      assert_raises ActiveRecord::RecordInvalid do
        @posting.save!
      end
    end

    it "allow negative amounts" do
      @posting.attributes = posting_attributes
      @posting.amount = -0.01
      @posting.should be_valid
      assert_nothing_raised do
        @posting.save!
      end
    end

    it "allow positive amounts" do
      @posting.attributes = posting_attributes
      @posting.amount = 0.01
      @posting.should be_valid
      assert_nothing_raised do
        @posting.save!
      end
    end
  end

  context "#create" do
    it "should default transacted_on if not provided" do
      @posting.attributes = posting_attributes.except(:transacted_on)
      @posting.save!
      assert_equal Date.parse(@posting.created_at.to_s), Date.parse(@posting.transacted_on.to_s)
    end

    it "should not default transacted_on if provided" do
      @posting.attributes = posting_attributes
      t_on = Time.now + 3.days
      @posting.transacted_on = t_on
      @posting.save!
      assert_equal Date.parse(t_on.to_s), Date.parse(@posting.transacted_on.to_s)
    end

    it "should default conversion if type of asset not provided" do
      @posting.attributes = posting_attributes
      @posting.save!
      @posting.conversion.should == 1.00
    end

    it "should not default conversion if type of asset provided" do
      con = 3.42
      @posting.attributes = posting_attributes
      @posting.type_of_asset_id = TypeOfAsset.create!(:name => "widget", :conversion => con).id
      @posting.save!
      @posting.conversion.should == con
    end

  end

  context "#account_name" do
    it "return name of account" do
      @account = Account.generate!(:name => "account 1")
      @posting = Posting.spawn
      @account.postings << @posting
      @account.save!
      assert_equal @account.name, @posting.account_name
    end
  end

  context "posting should be change from cleared " do
    it "to reconciled" do
       @journal1 = Journal.generate!(:description => "funding")
       @posting1 = Posting.spawn(:amount => 1.00, :memo => "test", :state => "cleared")
       @journal1.postings << @posting1
       @posting1.reconcile!
       @posting1.state.should == "reconciled"
    end
    it "to uncleared" do
       @journal2 = Journal.generate!(:description => "funding")
       @posting2 = Posting.spawn(:amount => 1.00, :memo => "test", :state => "cleared")
       @journal2.postings << @posting2
       @posting2.unclear!
       @posting2.state.should == "uncleared"
    end
  end

  context "posting should be change from uncleared " do
    it "to cleared" do
       @journal1 = Journal.generate!(:description => "funding")
       @posting1 = Posting.spawn(:amount => 1.00, :memo => "test")
       @journal1.postings << @posting1
       @posting1.clear!
       @posting1.state.should == "cleared"
    end
  end

  context "posting should be change from reconciled" do
    it "to uncleared" do
       @journal1 = Journal.generate!(:description => "funding")
       @posting1 = Posting.spawn(:amount => 1.00, :memo => "test", :state => "reconciled")
       @journal1.postings << @posting1
       @posting1.unclear!
       @posting1.state.should == "uncleared"
    end
  end
end
