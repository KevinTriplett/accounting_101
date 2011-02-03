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

  context "Should not be created if" do
    it "description blank" do
      @journal.attributes = journal_attributes.except(:description)
      @journal.save
      @journal.should have(1).error_on(:description)
      @journal.should_not be_valid
    end
  end

  context "should be created if" do
    it "all details are entered" do
      @journal.attributes = journal_attributes
      @journal.save
      @journal.should be_valid
    end
  end

  context "Check function" do
    before(:each) do
      @type_of_account = TypeOfAsset.create(:name => "gbp")
      @account_a = Account.generate(:name => "a", :type_of_account_id => @type_of_account.id)
      @account_b = Account.generate(:name => "b", :type_of_account_id => @type_of_account.id)
      @account_c = Account.generate(:name => "c", :type_of_account_id => @type_of_account.id)

      @posting_1 = Posting.spawn(:amount => -150)
      @posting_2 = Posting.spawn(:amount => 50)
      @posting_3 = Posting.spawn(:amount => 100)
      @posting_4 = Posting.spawn(:amount => -100)

      @posting_1.account = @account_a
      @posting_2.account = @account_b
      @posting_3.account = @account_c
      @posting_4.account = @account_c

      @journal_1 = Journal.generate(:description => "funding", :batch_id => 1)
      @journal_1.postings << @posting_1
      @journal_1.postings << @posting_2
      @journal_1.postings << @posting_3

      @journal_2 = Journal.generate(:description => "transfer", :batch_id => 1)
      @journal_2.postings << @posting_1
      @journal_2.postings << @posting_2

      @journal_3 = Journal.generate(:description => "funding", :batch_id => 1)
      @journal_3.postings << @posting_3
      @journal_3.postings << @posting_4

    end
    it "postings is balanced" do
      valid = @journal_1.postings_are_balanced?
      if valid 
        @journal_1.should be_valid
      else
        @journal_1.should_not be_valid
      end
    end

    it "detect postings that do not balance" do
      not_valid = !@journal_2.postings_are_balanced?
      if !not_valid 
        @journal_1.should_not be_valid
      else
        @journal_1.should be_valid
      end
    end
  end

  context "validations" do
    before(:each) do
      @account_a = Account.generate(:name => "a")
      @account_b = Account.generate(:name => "b")
      @account_c = Account.generate(:name => "c")

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
      @journal = Journal.generate(:description => "transfer", :batch_id => 1)
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

  #same copy form unit test for understanding
  context "all journals class method" do
    before(:each) do
      @batch = Batch.generate
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

      @j1 = Journal.spawn(:description => "journal 1", :batch_id => @batch.id)
      @j2 = Journal.spawn(:description => "journal 2", :batch_id => @batch.id)
      @j3 = Journal.spawn(:description => "journal 3", :batch_id => @batch.id)
      @j4 = Journal.spawn(:description => "journal 4", :batch_id => @batch.id)
      @j5 = Journal.spawn(:description => "journal 5", :batch_id => @batch.id)

      @j1.save!
      @j2.save!
      @j3.save!
      @j4.save!
      @j5.save!

      @j1.postings << @p1CR
      @j1.postings << @p1DR
      @j2.postings << @p2CR
      @j2.postings << @p2DR
      @j3.postings << @p3CR
      @j3.postings << @p3DR
      @j4.postings << @p4CR
      @j4.postings << @p4DR
      @j5.postings << @p5CR
      @j5.postings << @p5DR


      @a1.save!
      @a2.save!
      @a3.save!
    end

    it "return all journals unfiltered" do
      assert_equal [@j1, @j2, @j3, @j4, @j5].map(&:description).to_set, Journal.all_journals.map(&:description).to_set
    end

    it "return all journals filtered" do
      assert_equal [@j1, @j3, @j4].map(&:description).to_set, Journal.all_journals(@a1.id).map(&:description).to_set
      assert_equal [@j1, @j3, @j4].map(&:description).to_set, Journal.all_journals(@a1.id).map(&:description).to_set
    end
  end
end
