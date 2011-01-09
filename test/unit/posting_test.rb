require 'test_helper'

class PostingTest < ActiveSupport::TestCase

  should belong_to :account
  should belong_to :journal

  should validate_presence_of :amount

  should validate_numericality_of :amount

  # should validate_exclusion_of :amount, :in => [0]
  context "validations" do
    setup do
      @posting = Posting.spawn
    end

    should "not allow zero amounts" do
      @posting.amount = 0.00
      assert_raises ActiveRecord::RecordInvalid do
        @posting.save!
      end
    end

    should "allow negative amounts" do
      @posting.amount = -1.00
      assert_nothing_raised do
        @posting.save!
      end
    end

    should "allow positive amounts" do
      @posting.amount = 1.00
      assert_nothing_raised do
        @posting.save!
      end
    end
  end

  context "named scopes" do
    setup do
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

    should "have credits" do
      assert_equal [@posting_3, @posting_4].map(&:amount).to_set, @account.postings.credit.map(&:amount).to_set
    end

    should "have debits" do
      assert_equal [@posting_1, @posting_2].map(&:amount).to_set, @account.postings.debit.map(&:amount).to_set
    end
  end

  context "after_create" do
    should "default transacted_on attribute to journal.created_at" do
      pretend_now_is(Time.local(2010,"jul",5,9)) do
        @journal = Journal.generate
      end
      pretend_now_is(Time.local(2012,"aug",2,9)) do
        @posting_1 = Posting.spawn(:amount =>  1.00, :transacted_on => nil)
        @journal.postings << @posting_1
        assert_equal Date.parse(@journal.created_at.to_s), Date.parse(@posting_1.transacted_on.to_s)
      end
    end
  end

  context "#account_name" do
    should "return name of account" do
      @account = Account.generate(:name => "account 1")
      @posting = Posting.spawn
      @account.postings << @posting
      @account.save!
      assert_equal @account.name, @posting.account_name
    end
  end

  context "#credit/debit test" do
    setup do
      @posting_1 = Posting.spawn(:amount =>  1.00)
      @posting_2 = Posting.spawn(:amount => -2.00)
    end

    should "indicate credit when amount < 0" do
      assert  @posting_2.credit?
      assert !@posting_1.credit?
    end

    should "indicate debit when amount > 0" do
      assert  @posting_1.debit?
      assert !@posting_2.debit?
    end
  end

  context "#all_postings class method" do
    setup do
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

      # @j1 = Journal.spawn(:description => "journal 1")
      # @j2 = Journal.spawn(:description => "journal 2")
      # @j3 = Journal.spawn(:description => "journal 3")
      # @j4 = Journal.spawn(:description => "journal 4")
      # @j5 = Journal.spawn(:description => "journal 5")
      #
      # @j1.postings << @p1CR
      # @j1.postings << @p1DR
      # @j2.postings << @p2CR
      # @j2.postings << @p2DR
      # @j3.postings << @p3CR
      # @j3.postings << @p3DR
      # @j4.postings << @p4CR
      # @j4.postings << @p4DR
      # @j5.postings << @p5CR
      # @j5.postings << @p5DR
      #
      # @j1.save!
      # @j2.save!
      # @j3.save!
      # @j4.save!
      # @j5.save!

      @a1.save!
      @a2.save!
      @a3.save!
    end

    should "return all postings unfiltered" do
      assert_equal [@p1CR, @p1DR, @p2CR, @p2DR, @p3CR, @p3DR, @p4CR, @p4DR, @p5CR, @p5DR].map(&:amount).to_set, Posting.all_postings.map(&:amount).to_set
    end

    should "return all postings filtered" do
      assert_equal [@p1CR, @p3DR, @p4CR].map(&:amount).to_set, Posting.all_postings(@a1.id).map(&:amount).to_set
    end
  end

end
