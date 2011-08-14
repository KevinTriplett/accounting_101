require 'spec_helper'

describe Journal do
  context "should not be created if" do
    it "description is blank" do
      journal = Journal.spawn(:description => "")
      journal.should_not be_valid
      journal.should have(1).error_on(:description)
      assert_raises ActiveRecord::RecordInvalid do
        journal.save!
      end
    end

    it "description is nil" do
      journal = Journal.spawn(:description => nil)
      journal.should_not be_valid
      journal.should have(1).error_on(:description)
      assert_raises ActiveRecord::RecordInvalid do
        journal.save!
      end
    end
  end

  context "should be created if" do
    it "all attributes correct" do
      journal = Journal.spawn
      assert_nothing_raised do
        journal.save!
      end
      journal.should be_valid
    end
  end

  context "balance check" do
    before(:each) do
      @journal = Journal.generate!
      debit = TypeOfAccount.create!(:name => "debit", :debit => true)
      credit = TypeOfAccount.create!(:name => "credit", :debit => false)
      @account_debit = Account.generate!(:name => "debit account", :type_of_account_id => debit.id)
      @account_credit = Account.generate!(:name => "credit account", :type_of_account_id => credit.id)
    end

    it "detect if postings are balanced" do
      @journal.postings << Posting.spawn(:amount =>  15.00, :account_id => @account_debit.id)
      @journal.postings << Posting.spawn(:amount => -15.00, :account_id => @account_debit.id)
      @journal.postings << Posting.spawn(:amount =>  10.00, :account_id => @account_credit.id)
      @journal.postings << Posting.spawn(:amount => -10.00, :account_id => @account_credit.id)
      @journal.should be_balanced
    end

    it "detect if postings are not balanced, credit edge case" do
      @journal.postings << Posting.spawn(:amount =>  10.00, :account_id => @account_credit.id)
      @journal.postings << Posting.spawn(:amount => -10.00, :account_id => @account_credit.id)
      @journal.postings << Posting.spawn(:amount =>  -0.01, :account_id => @account_credit.id)
      @journal.should_not be_balanced
    end

    it "detect if postings are not balanced, debit edge case" do
      @journal.postings << Posting.spawn(:amount =>  -0.01, :account_id => @account_debit.id)
      @journal.postings << Posting.spawn(:amount =>  15.00, :account_id => @account_debit.id)
      @journal.postings << Posting.spawn(:amount => -15.00, :account_id => @account_debit.id)
      @journal.should_not be_balanced
    end

    it "validate postings that balance" do
      @journal.postings << Posting.spawn(:amount =>  15.00, :account_id => @account_debit.id)
      @journal.postings << Posting.spawn(:amount => -15.00, :account_id => @account_debit.id)
      @journal.postings << Posting.spawn(:amount =>  10.00, :account_id => @account_credit.id)
      @journal.postings << Posting.spawn(:amount => -10.00, :account_id => @account_credit.id)
      @journal.should be_valid
      assert_nothing_raised do
        @journal.save!
      end
    end

    it "not validate postings that do not balance, debit edge case" do
      @journal.postings << Posting.spawn(:amount =>   0.01, :account_id => @account_debit.id)
      @journal.postings << Posting.spawn(:amount =>  15.00, :account_id => @account_debit.id)
      @journal.postings << Posting.spawn(:amount => -15.00, :account_id => @account_debit.id)
      @journal.should_not be_valid
      @journal.should have(1).error_on(:postings)
      assert_raises(ActiveRecord::RecordInvalid, "must balance (sum to zero)") do
        @journal.save!
      end
    end

    it "not validate postings that do not balance, credit edge case" do
      @journal.postings << Posting.spawn(:amount =>  10.00, :account_id => @account_credit.id)
      @journal.postings << Posting.spawn(:amount => -10.00, :account_id => @account_credit.id)
      @journal.postings << Posting.spawn(:amount =>   0.01, :account_id => @account_credit.id)
      @journal.should_not be_valid
      @journal.should have(1).error_on(:postings)
      assert_raises(ActiveRecord::RecordInvalid, "must balance (sum to zero)") do
        @journal.save!
      end
    end
  end
end
