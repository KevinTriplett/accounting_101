require 'spec_helper'

describe Batch do
  context "Batch Should be" do
    it "created in opened state" do
      @b = Batch.generate
      assert_equal @b.state, "opened"
    end
    
    it "assign to journal when creating" do
      @b = Batch.generate
      @j = Journal.generate(:description => "funding", :batch_id => @b)
      assert_equal @j.batch.state, "opened"
    end
  end

  context "batch should be change from" do
    it "opened to closed" do
      @batch1 = Batch.generate
      @batch1.close!
      @batch1.should be_valid
    end
    
    it "reopened to closed" do
      @batch1 = Batch.generate
      @batch1.state = "reopened"
      @batch1.save!
      @batch1.close!
      @batch1.should be_valid
    end

    it "closed to reopened" do
      @batch1 = Batch.generate
      @batch1.state = "closed"
      @batch1.save!
      @batch1.reopen!
      @batch1.should be_valid
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

  context "posting should not be updated" do
    it "if batch is closed" do
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
end
