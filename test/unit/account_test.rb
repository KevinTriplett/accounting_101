require 'test_helper'

class AccountTest < ActiveSupport::TestCase

  should belong_to :type_of_account
  should have_many :postings
  should have_many :subaccounts
  should belong_to :parent

  should validate_presence_of :name

  # should validate_uniqueness_of :name, :case_sensitive => false
  context "validations" do
    setup do
      @account_1 = Account.spawn(:name => "account 1")
      @account_1.type_of_account_id = 123
      @account_1.save!
    end

    should "ensure unique names" do
      assert_raises ActiveRecord::RecordInvalid do
        account = Account.spawn(:name => "account 1")
        account.type_of_account_id = 123
        account.save!
      end
    end

    should "ensure unique case insensitive names" do
      assert_raises ActiveRecord::RecordInvalid do
        account = Account.spawn(:name => "Account 1")
        account.type_of_account_id = 123
        account.save!
      end
    end

    should "allow different name" do
      assert_nothing_raised do
        account = Account.spawn(:name => "Account 2")
        account.type_of_account_id = 123
        account.save!
      end
    end
  end

  context "#ancestors" do
    setup do
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

    should "return lineage of ancestors for account" do
      assert_equal [@account_1, @account_2, @account_3].map(&:name).to_set, @account_5.ancestors.map(&:name).to_set
    end

    should "return empty set of ancestors for account" do
      assert @account_1.ancestors.size == 0
    end
  end

  context "#descendants" do
    setup do
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

    should "return lineage of descendants for account" do
      assert_equal [@account_2, @account_3, @account_4, @account_5].map(&:name).to_set, @account_1.descendants.map(&:name).to_set
    end

    should "return empty set of descendants for account" do
      assert @account_4.descendants.size == 0
      assert @account_5.descendants.size == 0
    end
  end

  context "#destroy" do
    setup do
      @account_1 = Account.generate
      @posting_1 = @account_1.postings.build
    end

    should "not orphan postings" do
      assert_raises Account::OrphanPostings do
        @account_1.destroy
      end
    end

    should "allow destroy with empty postings" do
      assert_nothing_raised do
        @account_1.postings.delete_all
        @account_1.destroy
      end
    end
  end

  context "#all_postings" do
    setup do
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
      # parent    <- child     <- child
      # account 1 <- account 2 <- account 3
      @account_3.parent = @account_2
      @account_2.parent = @account_1
      @account_1.save!
      @account_2.save!
      @account_3.save!
    end

    should "return array of postings from self and children" do
      assert_equal [@posting_1, @posting_2, @posting_3, @posting_4].map(&:amount).to_set, @account_1.all_postings.map(&:amount).to_set
    end

    should "return array of postings from just self if no children" do
      assert_equal [@posting_3, @posting_4].map(&:amount).to_set, @account_3.all_postings.map(&:amount).to_set
    end
  end

end
