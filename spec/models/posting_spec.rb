require 'spec_helper'

def posting_attributes
  {
    :account_id => 123,
    :journal_id => 1,
    :type_of_asset_id => 1,
    :amount => 10.1
  }
end

describe Posting do
  before(:each) do
    @posting = Posting.new
  end

  context "Should not be created if" do
    it "amount is blank" do
      @posting.attributes = posting_attributes.except(:amount)
      @posting.save
      @posting.should have(1).error_on(:amount)
      @posting.should_not be_valid
    end         

    it "account_id is blank" do
      @posting.attributes = posting_attributes.except(:account_id)
      @posting.save
      @posting.should have(1).error_on(:account_id)
      @posting.should_not be_valid
    end         

    it "journal is blank" do
      @posting.attributes = posting_attributes.except(:journal_id)
      @posting.save
      @posting.should have(1).error_on(:journal_id)
      @posting.should_not be_valid
    end         

    it "type_of_asset_id is blank" do
      @posting.attributes = posting_attributes.except(:type_of_asset_id)
      @posting.save
      @posting.should have(1).error_on(:type_of_asset_id)
      @posting.should_not be_valid
    end         
  end               

  context "should be created if" do
    it "all details are entered" do
      @posting.attributes = posting_attributes
      @posting.save
      @posting.should be_valid
    end           
  end   

  context "validations" do
    before(:each) do
      @posting = Posting.spawn
    end

    it "not allow zero amounts" do
      @posting.amount = 0.00
      assert_raises ActiveRecord::RecordInvalid do
        @posting.save!
      end
    end

    it "allow negative amounts" do
      @posting.amount = -1.00
      assert_nothing_raised do
        @posting.save!
      end
    end

    it "allow positive amounts" do
      @posting.amount = 1.00
      assert_nothing_raised do
        @posting.save!
      end
    end
  end

  context "named scopes" do
    before(:each) do
      @account = Account.generate
      @posting_1 = Posting.spawn(:amount =>  1.00)
      @posting_2 = Posting.spawn(:amount =>  2.00)
      @posting_3 = Posting.spawn(:amount => -3.00)
      @posting_4 = Posting.spawn(:amount => -4.00)
      @account.postings << @posting_1
      @account.postings << @posting_2
      @account.postings << @posting_3
      @account.postings << @posting_4
      @account.save!
    end

    it "have credits" do
      assert_equal [@posting_3, @posting_4].map(&:amount).to_set, @account.postings.credit.map(&:amount).to_set
    end

    it "have debits" do
      assert_equal [@posting_1, @posting_2].map(&:amount).to_set, @account.postings.debit.map(&:amount).to_set
    end
  end

  context "after_create" do
    it "default transacted_on attribute to journal.created_at" do
        @journal = Journal.generate(:description => "funding", :batch_id => 1)
        @posting_1 = Posting.spawn(:amount =>  1.00, :transacted_on => nil)
        @journal.postings << @posting_1
        assert_equal Date.parse(@journal.created_at.to_s), Date.parse(@posting_1.transacted_on.to_s)
    end
  end

  context "#account_name" do
    it "return name of account" do
      @account = Account.generate(:name => "account 1")
      @posting = Posting.spawn
      @account.postings << @posting
      @account.save!
      assert_equal @account.name, @posting.account_name
    end
  end

  context "#credit/debit test" do
    before(:each) do
      @posting_1 = Posting.spawn(:amount =>  1.00)
      @posting_2 = Posting.spawn(:amount => -2.00)
    end

    it "indicate credit when amount < 0" do
      assert  @posting_2.credit?
      assert !@posting_1.credit?
    end

    it "indicate debit when amount > 0" do
      assert  @posting_1.debit?
      assert !@posting_2.debit?
    end
  end

  context "#all_postings class method" do
    before(:each) do
      @a1 = Account.generate(:name => "account 1")
      @a2 = Account.generate(:name => "account 2")
      @a3 = Account.generate(:name => "account 3")

      @p1CR = Posting.spawn(:amount => -1.00)
      @p1DR = Posting.spawn(:amount =>  1.00)
      @p2CR = Posting.spawn(:amount => -2.00)
      @p2DR = Posting.spawn(:amount =>  2.00)
      @p3CR = Posting.spawn(:amount => -3.00)
      @p3DR = Posting.spawn(:amount =>  3.00)
      @p4CR = Posting.spawn(:amount => -4.00)
      @p4DR = Posting.spawn(:amount =>  4.00)
      @p5CR = Posting.spawn(:amount => -5.00)
      @p5DR = Posting.spawn(:amount =>  5.00)

      @a1.postings << @p1CR
      @a2.postings << @p1DR
      @a2.postings << @p2CR
      @a3.postings << @p2DR
      @a3.postings << @p3CR
      @a1.postings << @p3DR
      @a1.postings << @p4CR
      @a3.postings << @p4DR
      @a3.postings << @p5CR
      @a2.postings << @p5DR

      @a1.save!
      @a2.save!
      @a3.save!
    end

    it "return all postings unfiltered" do
      assert_equal [@p1CR, @p1DR, @p2CR, @p2DR, @p3CR, @p3DR, @p4CR, @p4DR, @p5CR, @p5DR].map(&:amount).to_set, Posting.all_postings.map(&:amount).to_set
    end

    it "return all postings filtered" do
      assert_equal [@p1CR, @p3DR, @p4CR].map(&:amount).to_set, Posting.all_postings(@a1.id).map(&:amount).to_set
    end
  end

  context "posting should be change from cleared " do
    it "to reconciled" do
       @batch1 = Batch.generate
       @journal1 = Journal.generate(:description => "funding", :batch_id => @batch1)
       @posting1 = Posting.spawn(:amount => 1.00, :memo => "test", :state => "cleared")
       @journal1.postings << @posting1
       @posting1.reconcile!
       @posting1.should be_valid 
    end
    it "to uncleared" do
       @batch1 = Batch.generate
       @journal2 = Journal.generate(:description => "funding", :batch_id => @batch1)
       @posting2 = Posting.spawn(:amount => 1.00, :memo => "test", :state => "cleared")
       @journal2.postings << @posting2
       @posting2.unclear!
       @posting2.should be_valid 
    end
  end

  context "posting should be change from uncleared " do
    it "to cleared" do
       @batch1 = Batch.generate
       @journal1 = Journal.generate(:description => "funding", :batch_id => @batch1)
       @posting1 = Posting.spawn(:amount => 1.00, :memo => "test")
       @journal1.postings << @posting1
       @posting1.clear!
       @posting1.should be_valid 
    end
  end

  context "posting should be change from reconciled" do
    it "to uncleared if batch is opened" do
       @batch1 = Batch.generate
       @journal1 = Journal.generate(:description => "funding", :batch_id => @batch1)
       @posting1 = Posting.spawn(:amount => 1.00, :memo => "test", :state => "reconciled")
       @journal1.postings << @posting1
       @posting1.unclear!
       @posting1.should be_valid 
    end
    it "to uncleared if batch is reopened" do
       @batch1 = Batch.generate
       @journal1 = Journal.generate(:description => "funding", :batch_id => @batch1)
       @batch1.state = "reopened"
       @batch1.save!
       @posting1 = Posting.spawn(:amount => 1.00, :memo => "test", :state => "reconciled")
       @journal1.postings << @posting1
       @posting1.unclear!
       @posting1.should be_valid 
    end
  end

  context "posting should not be change from reconciled" do
    it "to uncleared if batch is closed" do
      assert_raises Posting::UpdateNotAllow do
       @batch1 = Batch.generate
       @journal1 = Journal.generate(:description => "funding", :batch_id => @batch1)
       @posting1 = Posting.spawn(:amount => 1.00, :memo => "test", :state => "reconciled")
       @journal1.postings << @posting1
       @batch1 =  @journal1.batch
       @batch1.state = "closed"
       @batch1.save
       @posting1.unclear!
       @posting1.should_not be_valid 
      end
    end
  end

  context "posting should be created if " do
    it "batch has closed" do
       @batch1 = Batch.generate
       @journal1 = Journal.generate(:description => "funding", :batch_id => @batch1)
       @batch1.state = "closed"
       @batch1.save!
       @posting1 = Posting.spawn(:amount => 1.00, :memo => "test",:journal_id => @journal1.id)
       @posting1.should be_valid
    end
  end
  context "batch in reopened state then" do
    before(:each) do
       @b = Batch.generate
       @b.state = "reopened"
       @b.save!
    end
    it "add new posting" do
       @j = Journal.generate(:description => "funding", :batch_id => @b)
       @p = Posting.spawn(:amount => 1.00, :memo => "test")
       @j.postings << @p
    end
    it "update a posting" do
       @j = Journal.generate(:description => "funding", :batch_id => @b)
       @p = Posting.spawn(:amount => 1.00, :memo => "test")
       @j.postings << @p
       @p.amount = 10.00
       @p.save!
    end
    it "delete a posting" do
       @j = Journal.generate(:description => "funding", :batch_id => @b)
       @p = Posting.spawn(:amount => 1.00, :memo => "test")
       @j.postings << @p
       @p.destroy
    end
  end
end
