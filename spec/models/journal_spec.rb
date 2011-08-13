require 'spec_helper'

def journal_attributes
  {
    :description => "funding"
  }
end
describe Journal do
  before(:each) do
    @journal = Journal.new
  end

  context "should not be created if" do
    it "description blank" do
      @journal.attributes = journal_attributes.except(:description)
      @journal.save # save! will raise error
      @journal.should have(1).error_on(:description)
      @journal.should_not be_valid
    end
  end

  context "should be created if" do
    it "all details are entered" do
      @journal.attributes = journal_attributes
      @journal.save!
      @journal.should be_valid
    end
  end

  context "should detect" do
    before(:each) do
      @type_of_account = TypeOfAsset.create!(:name => "gbp", :conversion => 1)
      @account_a = Account.generate!(:name => "a", :type_of_account_id => @type_of_account.id)
      @account_b = Account.generate!(:name => "b", :type_of_account_id => @type_of_account.id)
      @account_c = Account.generate!(:name => "c", :type_of_account_id => @type_of_account.id)
      @account_d = Account.generate!(:name => "d", :type_of_account_id => @type_of_account.id)

      @posting_1 = Posting.spawn(:amount => -150)
      @posting_2 = Posting.spawn(:amount => 50)
      @posting_3 = Posting.spawn(:amount => 100)
      @posting_low = Posting.spawn(:amount => -0.01)
      @posting_high = Posting.spawn(:amount => 0.01)

      @posting_1.account = @account_a
      @posting_2.account = @account_b
      @posting_3.account = @account_c
      @posting_low.account = @account_d
      @posting_high.account = @account_d

      @journal_balanced = Journal.generate!(:description => "balanced", :batch_id => 1)
      @journal_balanced.postings << @posting_1
      @journal_balanced.postings << @posting_2
      @journal_balanced.postings << @posting_3

      @journal_unbalanced = Journal.generate!(:description => "unbalanced", :batch_id => 1)
      @journal_unbalanced.postings << @posting_1
      @journal_unbalanced.postings << @posting_2

      @journal_unbalanced_high_edge_case = Journal.generate!(:description => "off by smallest unit high", :batch_id => 1)
      @journal_unbalanced_high_edge_case.postings << @posting_1
      @journal_unbalanced_high_edge_case.postings << @posting_2
      @journal_unbalanced_high_edge_case.postings << @posting_3
      @journal_unbalanced_high_edge_case.postings << @posting_high

      @journal_unbalanced_low_edge_case = Journal.generate!(:description => "off by smallest unit low", :batch_id => 1)
      @journal_unbalanced_low_edge_case.postings << @posting_1
      @journal_unbalanced_low_edge_case.postings << @posting_2
      @journal_unbalanced_low_edge_case.postings << @posting_3
      @journal_unbalanced_low_edge_case.postings << @posting_low

      @journal_balanced_edge_case = Journal.generate!(:description => "balanced", :batch_id => 1)
      @journal_balanced_edge_case.postings << @posting_1
      @journal_balanced_edge_case.postings << @posting_2
      @journal_balanced_edge_case.postings << @posting_3
      @journal_balanced_edge_case.postings << @posting_low
      @journal_balanced_edge_case.postings << @posting_high
    end

    it "if postings are balanced" do
      @journal_balanced.should be_balanced
    end

    it "if postings are not balanced" do
      @journal_unbalanced.should_not be_balanced
    end

    it "if postings are not balanced, high edge case" do
      @journal_unbalanced_high_edge_case.should_not be_balanced
    end

    it "if postings are not balanced, low edge case" do
      @journal_unbalanced_low_edge_case.should_not be_balanced
    end

    it "if postings are balanced, edge case" do
      @journal_balanced_edge_case.should be_balanced
    end
  end

  context "validations" do
    before(:each) do
      @account_a = Account.generate!(:name => "a")
      @account_b = Account.generate!(:name => "b")
      @account_c = Account.generate!(:name => "c")

      @posting_1 = Posting.spawn(:amount => -150)
      @posting_2 = Posting.spawn(:amount => 50)
      @posting_3 = Posting.spawn(:amount => 100)
      @posting_4 = Posting.spawn(:amount => -100)
      @posting_5 = Posting.spawn(:amount => -100)

      @posting_1.account = @account_a
      @posting_2.account = @account_b
      @posting_3.account = @account_c
      @posting_4.account = @account_c
      @posting_5.account = @account_b
      @journal = Journal.generate!(:description => "transfer", :batch_id => 1)
    end

    it "validate postings that balance" do
      assert_nothing_raised do
        @journal.postings << @posting_1
        @journal.postings << @posting_2
        @journal.postings << @posting_3
        @journal.save!
      end
    end

    it "do not validate postings that do not balance" do
      assert_raises(ActiveRecord::RecordInvalid, "postings do not sum to zero") do
        @journal.postings << @posting_1
        @journal.postings << @posting_2
        @journal.save!
      end
    end
  end
end
