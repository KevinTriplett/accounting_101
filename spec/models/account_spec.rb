require 'spec_helper'

describe "Account" do
  context "should not be created if" do
    it "account name is blank" do
      account = Account.spawn(:name => "")
      account.should_not be_valid
      account.should have(1).error_on(:name)
      assert_raises ActiveRecord::RecordInvalid do
        account.save!
      end
    end

    it "account name is nil" do
      account = Account.spawn(:name => nil)
      account.should_not be_valid
      account.should have(1).error_on(:name)
      assert_raises ActiveRecord::RecordInvalid do
        account.save!
      end
    end

    it "account name is not unique" do
      account = Account.generate!(:name => "account duplicate")
      account_dup = Account.spawn(:name => "account duplicate")
      account_dup.should_not be_valid
      account_dup.should have(1).error_on(:name)
      assert_raises ActiveRecord::RecordInvalid do
        account_dup.save!
      end
    end

    it "account name is not unique, case insensitive" do
      account = Account.generate!(:name => "account duplicate")
      account_dup = Account.spawn(:name => "Account duplicate")
      account_dup.should_not be_valid
      account_dup.should have(1).error_on(:name)
      assert_raises ActiveRecord::RecordInvalid do
        account_dup.save!
      end
    end
  end

  context "should be created if" do
    it "all attributes correct" do
      account = Account.spawn
      assert_nothing_raised do
        account.save!
      end
      account.should be_valid
    end

    it "account names unique" do
      account = Account.generate!(:name => "account duplicate")
      account_not_dup = Account.spawn(:name => "account not duplicate")
      assert_nothing_raised do
        account_not_dup.save!
      end
      account_not_dup.should be_valid
    end
  end

  context "#ancestors" do
    before(:each) do
      @account_1 = Account.generate!(:name => "account 1")
      @account_2 = Account.generate!(:name => "account 2")
      @account_3 = Account.generate!(:name => "account 3")
      @account_4 = Account.generate!(:name => "account 4")
      @account_5 = Account.generate!(:name => "account 5")
      @account_1.subaccounts << @account_2
      @account_2.subaccounts << @account_3
      @account_3.subaccounts << @account_4
      @account_3.subaccounts << @account_5
      [@account_1,@account_2,@account_3].each(&:save!)
    end

    it "return lineage of ancestors for account" do
      assert_equal [@account_1, @account_2, @account_3].map(&:name).to_set, @account_5.ancestors.map(&:name).to_set
    end

    it "return empty set of ancestors for account" do
      assert @account_1.ancestors.empty?
    end
  end

  context "#descendants" do
    before(:each) do
      @account_1 = Account.generate!(:name => "account 1")
      @account_2 = Account.generate!(:name => "account 2")
      @account_3 = Account.generate!(:name => "account 3")
      @account_4 = Account.generate!(:name => "account 4")
      @account_5 = Account.generate!(:name => "account 5")
      @account_1.subaccounts << @account_2
      @account_2.subaccounts << @account_3
      @account_3.subaccounts << @account_4
      @account_3.subaccounts << @account_5
      [@account_1,@account_2,@account_3].each(&:save!)
    end

    it "return lineage of descendants for account" do
      assert_equal [@account_2, @account_3, @account_4, @account_5].map(&:name).to_set, @account_1.descendants.map(&:name).to_set
    end

    it "return empty set of descendants for account" do
      assert @account_4.descendants.empty?
      assert @account_5.descendants.empty?
    end
  end

  context "#destroy" do
    before(:each) do
      @account = Account.generate!
      @posting = Posting.generate!(:account_id => @account.id)
    end

    it "should not orphan postings" do
      assert_raises Account::OrphanPostings do
        @account.destroy
      end
    end

    it "should destroy if doing so does not orphan postings" do
      @posting.destroy
      assert_nothing_raised do
        @account.destroy
      end
    end
  end

  context "#post" do
    before(:each) do
      debit = TypeOfAccount.create!(:name => "debit", :debit => true)
      credit = TypeOfAccount.create!(:name => "credit", :debit => false)
      @primary_debit = Account.generate!(:name => "primary debit", :type_of_account_id => debit.id)
      @primary_credit = Account.generate!(:name => "primary credit", :type_of_account_id => credit.id)
      @secondary_debit = Account.generate!(:name => "secondary debit", :type_of_account_id => debit.id)
      @secondary_credit = Account.generate!(:name => "secondary credit", :type_of_account_id => credit.id)
    end

    context "between two debit accounts" do
      it "should reverse the post amount" do
        journal = @primary_debit.post(100, @secondary_debit, "test description")
        assert_equal journal.postings[0].amount, -journal.postings[1].amount
      end         
    end
  end

  context "#all_postings" do
    before(:each) do
      @account_1 = Account.spawn(:name => "account 1")
      @account_2 = Account.spawn(:name => "account 2")
      @account_3 = Account.spawn(:name => "account 3")
      @account_3.parent = @account_2
      @account_2.parent = @account_1
      [@account_1, @account_2, @account_3].each(&:save!)

      @posting_1 = Posting.generate!(:amount =>  1.11, :account_id => @account_1.id)
      @posting_2 = Posting.generate!(:amount => -1.11, :account_id => @account_2.id)
      @posting_3 = Posting.generate!(:amount =>  3.33, :account_id => @account_3.id)
      @posting_4 = Posting.generate!(:amount => -3.33, :account_id => @account_3.id)
    end

    it "return array of postings from self and children" do
      assert_equal [@posting_1, @posting_2, @posting_3, @posting_4].map(&:amount).to_set, @account_1.all_postings.map(&:amount).to_set
    end

    it "return array of postings from just self if no children" do
      assert_equal [@posting_3, @posting_4].map(&:amount).to_set, @account_3.all_postings.map(&:amount).to_set
    end
  end

end
