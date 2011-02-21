require 'spec_helper'
describe Batch do
  context "Batch Should be" do
    it "created in opened state" do
      @b = Batch.generate
      assert_equal @b.state, "opened"
    end
  end

  context "Assign opened batch" do
    before(:each) do
      @batch = Batch.generate
    end

    it "when journal created" do
      @journal = Journal.new
      @journal.description = "funding"
      @journal.save!
      assert_equal @journal.batch, @batch
    end
  end

  context "If no batch opened and journal created then" do
    it "batch should be created in opened state" do
      @batch = Batch.generate
      @batch.close!
      @journal = Journal.new
      @journal.description = "funding"
      @journal.save!
      assert_equal @journal.batch.state, "opened"
      assert_not_equal @journal.batch, @batch
    end
  end


  context "batch should be change from" do
    it "opened to closed" do
      @batch1 = Batch.generate
      @batch1.close!
      @batch1.state.should == "closed"
    end
    
    it "reopened to closed" do
      @batch1 = Batch.generate
      @batch1.state = "reopened"
      @batch1.save!
      @batch1.close!
      @batch1.state.should == "closed"
    end

    it "closed to reopened" do
      @batch1 = Batch.generate
      @batch1.state = "closed"
      @batch1.save!
      @batch1.reopen!
      @batch1.state.should == "reopened"
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
      @j = Journal.generate!(:description => "funding", :batch_id => @b)
      @p = Posting.spawn(:amount => 1.00, :memo => "test")
      @j.postings << @p
      @p.amount = 10.00
      @p.save!
    end
    it "delete a posting" do
      @j = Journal.generate!(:description => "funding", :batch_id => @b)
      @p = Posting.spawn(:amount => 1.00, :memo => "test")
      @j.postings << @p
      @p.destroy
    end
  end

  context "batch is closed then " do
    it "posting should be added to journal" do
      @batch1 = Batch.generate!
      @journal1 = Journal.generate(:description => "funding", :batch_id => @batch1)
      @batch1 =  @journal1.batch
      @batch1.state = "closed"
      @batch1.save!
      @posting1 = Posting.new 
      @posting1.amount = 1.00
      @posting1.memo = "test"
      @posting1.journal_id = @journal1.id
      @posting1.type_of_asset_id = 1
      @posting1.account_id = 1
      @posting1.should be_valid
    end
    it "posting should not be updated" do
      @batch1 = Batch.generate!
      @journal1 = Journal.generate!(:description => "funding", :batch_id => @batch1)
      @posting1 = Posting.spawn(:amount => 1.00, :memo => "test", :state => "reconciled")
      @journal1.postings << @posting1
      @batch1 =  @journal1.batch
      @batch1.state = "closed"
      @batch1.save!
      @posting1.unclear!
      assert_equal @posting1.state, "reconciled"
    end

    it "posting should not be updated even amount change" do
      @batch1 = Batch.generate!
      @journal1 = Journal.generate!(:description => "funding", :batch_id => @batch1)
      @posting1 = Posting.spawn(:amount => 1.00, :memo => "test", :state => "reconciled")
      @journal1.postings << @posting1
      @batch1 =  @journal1.batch
      @batch1.close!
      @posting1.amount = 2.00
      @posting1.save
      @find_post = Posting.find(@posting1.id)
      assert_not_equal @find_post.amount.to_f, 2.00
    end

    it "posting should not be deleted" do
      @batch1 = Batch.generate!
      @journal1 = Journal.generate(:description => "funding", :batch_id => @batch1)
      @posting1 = Posting.spawn(:amount => 1.00, :memo => "test", :state => "reconciled")
      @journal1.postings << @posting1
      @batch1 =  @journal1.batch
      @batch1.state = "closed"
      @batch1.save!
      @posting1.destroy
      @find_post = Posting.find(@posting1.id) 
      @find_post.should_not == nil
    end
  end
end
