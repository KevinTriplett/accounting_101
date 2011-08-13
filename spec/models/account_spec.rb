require 'spec_helper'

def account_attributes
  {
    :name => "account_1", 
    :description => "description of account",
    :type_of_account_id => 123
  }
end

def type_of_account_attributes
  {
    :name => "asset",
    :debit => true
  }
end

describe "Account" do

  before(:each) do
    @account = Account.new
    @type_of_account = TypeOfAccount.new     
  end

  context "should not be created if" do
    it "account name is blank" do
      @account.attributes = account_attributes.except(:name)
      @account.save # save! will raise error
      @account.should have(1).error_on(:name)
      @account.should_not be_valid
    end

    it "account name is not unique" do
      @account.attributes = account_attributes.except(:type_of_account_id)
      @type_of_account.attributes = type_of_account_attributes
      @type_of_account.save!
      @account.type_of_account_id = @type_of_account.id
      @account.save!
      @account_2 = Account.new
      @account_2.attributes = account_attributes.except(:type_of_account_id)
      @account_2.type_of_account_id = @type_of_account.id
      @account_2.should have(1).error_on(:name)
      @account_2.should_not be_valid
    end

    it "account name is not unique case insensitive" do
      @account.attributes = account_attributes
      @type_of_account.attributes = type_of_account_attributes
      @type_of_account.save!
      @account.type_of_account_id = @type_of_account.id
      @account.save!
      @account_2 = Account.new
      @account_2.attributes = account_attributes.except(:name)
      @account_2.name = "Account_1"
      @account_2.type_of_account_id = @type_of_account.id
      @account_2.should have(1).error_on(:name)
      @account_2.should_not be_valid
    end
  end

  context "should be created if" do
    it "all details are entered" do
      @account.attributes = account_attributes.except(:name)
      @account.name = "1234"
      @type_of_account.attributes = type_of_account_attributes
      @type_of_account.save!
      @account.type_of_account_id = @type_of_account.id
      @account.should be_valid
    end

    it "with different name" do
      @account.attributes = account_attributes
      @account.name = "account_2"
      @type_of_account.attributes = type_of_account_attributes
      @type_of_account.save!
      @account.type_of_account_id = @type_of_account.id
      @account.should be_valid
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
      @account_1 = Account.generate!
      @posting_1 = @account_1.postings.build(:amount => 2.00)
      @posting_1.journal_id = 123
      @posting_1.type_of_asset_id = 321
      @posting_1.save!
    end

    it "not orphan postings" do
      assert_raises Account::OrphanPostings do
        @account_1.destroy
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
      @journal1 = Journal.generate!(:description => "funding1")
      @journal2 = Journal.generate!(:description => "funding2")
      @account_1 = Account.generate!(:name => "account 1")
      @account_2 = Account.generate!(:name => "account 2")
      @account_3 = Account.generate!(:name => "account 3")
      @posting_1 = Posting.generate!(:amount => 1.11)
      @posting_2 = Posting.generate!(:amount => -1.11)
      @posting_3 = Posting.generate!(:amount => 3.33)
      @posting_4 = Posting.generate!(:amount => -3.33)

      @journal1.postings << @posting_1
      @journal1.postings << @posting_2
      @journal2.postings << @posting_3
      @journal2.postings << @posting_4

      @account_1.postings << @posting_1
      @account_2.postings << @posting_2
      @account_3.postings << @posting_3
      @account_3.postings << @posting_4
      @account_3.parent = @account_2
      @account_2.parent = @account_1
      [@account_1, @account_2, @account_3].each(&:save!)
    end

    it "return array of postings from self and children" do
      assert_equal [@posting_1, @posting_2, @posting_3, @posting_4].map(&:amount).to_set, @account_1.all_postings.map(&:amount).to_set
    end

    it "return array of postings from just self if no children" do
      assert_equal [@posting_3, @posting_4].map(&:amount).to_set, @account_3.all_postings.map(&:amount).to_set
    end
  end

end
