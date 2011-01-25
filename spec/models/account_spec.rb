require 'spec_helper'

def account_attributes
  {
    :name => "account_1", 
    :description => "",
    :type_of_account_id => 123
  }
end

def type_of_account_attributes
  {
    :name => "asset"
  }
end

describe "Account" do

  before(:each) do
    @account = Account.new
    @type_of_account = TypeOfAccount.new     
  end

  context "Should not be created if" do
    it "account name is blank" do
      @account.attributes = account_attributes.except(:name)
      @account.save
      @account.should have(1).error_on(:name)
      @account.should_not be_valid
    end

    it "type of account is blank" do
      @account.attributes = account_attributes.except(:type_of_account_id)
      @account.should have(1).error_on(:type_of_account_id)
      @account.should_not be_valid
    end

    it "account name is not unique" do
      @account.attributes = account_attributes
      @type_of_account.attributes = type_of_account_attributes
      @type_of_account.save
      @account.type_of_account_id = @type_of_account.id
      @account.save
      @account_2 = Account.new
      @account_2.attributes = account_attributes
      @type_of_account.attributes = type_of_account_attributes
      @type_of_account.save
      @account.type_of_account_id = @type_of_account.id
      @account_2.should have(1).error_on(:name)
      @account_2.should_not be_valid
    end

    it "account name is not unique case insensitive" do
      @account.attributes = account_attributes
      @type_of_account.attributes = type_of_account_attributes
      @type_of_account.save
      @account.type_of_account_id = @type_of_account.id
      @account.save
      @account_2 = Account.new
      @account_2.attributes = account_attributes
      @account_2.name = "Account_1"
      @type_of_account.attributes = type_of_account_attributes
      @type_of_account.save
      @account.type_of_account_id = @type_of_account.id
      @account_2.should have(1).error_on(:name)
      @account_2.should_not be_valid
    end
  end

  context "should be created if" do
    it "all details are entered" do
      @account.attributes = account_attributes
      @account.name = "1234"
      @type_of_account.attributes = type_of_account_attributes
      @type_of_account.save
      @account.type_of_account_id = @type_of_account.id
      @account.should be_valid
    end

    it "with different name" do
      @account.attributes = account_attributes
      @account.name = "account_2"
      @type_of_account.attributes = type_of_account_attributes
      @type_of_account.save
      @account.type_of_account_id = @type_of_account.id
      @account.should be_valid
    end
  end

  context "#ancestors" do
    before(:each) do
      @account_1 = Account.generate(:name => "account 1")
      @account_2 = Account.generate(:name => "account 2")
      @account_3 = Account.generate(:name => "account 3")
      @account_4 = Account.generate(:name => "account 4")
      @account_5 = Account.generate(:name => "account 5")
      @account_1.subaccounts << @account_2
      @account_2.subaccounts << @account_3
      @account_3.subaccounts << @account_4
      @account_3.subaccounts << @account_5
    end

    it "return lineage of ancestors for account" do
      assert_equal [@account_1, @account_2, @account_3].map(&:name).to_set, @account_5.ancestors.map(&:name).to_set
    end

    it "return empty set of ancestors for account" do
      assert @account_1.ancestors.size == 0
    end
  end

  context "#descendants" do
    before(:each) do
      @account_1 = Account.generate(:name => "account 1")
      @account_2 = Account.generate(:name => "account 2")
      @account_3 = Account.generate(:name => "account 3")
      @account_4 = Account.generate(:name => "account 4")
      @account_5 = Account.generate(:name => "account 5")
      @account_1.subaccounts << @account_2
      @account_2.subaccounts << @account_3
      @account_3.subaccounts << @account_4
      @account_3.subaccounts << @account_5
      @account_1.save!
      @account_2.save!
      @account_3.save!
    end

    it "return lineage of descendants for account" do
      assert_equal [@account_2, @account_3, @account_4, @account_5].map(&:name).to_set, @account_1.descendants.map(&:name).to_set
    end

    it "return empty set of descendants for account" do
      assert @account_4.descendants.size == 0
      assert @account_5.descendants.size == 0
    end
  end

  context "#destroy" do
    before(:each) do
      @account_1 = Account.generate
      @posting_1 = @account_1.postings.build
    end

    it "not orphan postings" do
      assert_raises Account::OrphanPostings do
        @account_1.destroy
      end
    end

    it "allow destroy with empty postings" do
      assert_nothing_raised do
        @account_1.postings.delete_all
        @account_1.destroy
      end
    end
  end

  context "#all_postings" do
    before(:each) do
      @account_1 = Account.generate(:name => "account 1")
      @account_2 = Account.generate(:name => "account 2")
      @account_3 = Account.generate(:name => "account 3")
      @posting_1 = Posting.generate(:amount => "1.00")
      @posting_2 = Posting.generate(:amount => "2.00")
      @posting_3 = Posting.generate(:amount => "3.00")
      @posting_4 = Posting.generate(:amount => "4.00")
      @account_1.postings << @posting_1
      @account_2.postings << @posting_2
      @account_3.postings << @posting_3
      @account_3.postings << @posting_4
      @account_3.parent = @account_2
      @account_2.parent = @account_1
      @account_1.save!
      @account_2.save!
      @account_3.save!
    end

    it "return array of postings from self and children" do
      assert_equal [@posting_1, @posting_2, @posting_3, @posting_4].map(&:amount).to_set, @account_1.all_postings.map(&:amount).to_set
    end

    it "return array of postings from just self if no children" do
      assert_equal [@posting_3, @posting_4].map(&:amount).to_set, @account_3.all_postings.map(&:amount).to_set
    end
  end

end
