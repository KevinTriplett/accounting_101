require 'test_helper'

class JournalTest < ActiveSupport::TestCase

  should have_many :postings

  context "check functions" do
    setup do
      @account_a = Account.generate(:name => "a")
      @account_b = Account.generate(:name => "b")
      @account_c = Account.generate(:name => "c")

      @posting_1 = Posting.spawn(:amount => -150)
      @posting_2 = Posting.spawn(:amount => 50)
      @posting_3 = Posting.spawn(:amount => 100)
      @posting_4 = Posting.spawn(:amount => -100)

      @posting_1.account = @account_a
      @posting_2.account = @account_b
      @posting_3.account = @account_c
      @posting_4.account = @account_c

      @journal_1 = Journal.spawn
      @journal_1.postings << @posting_1
      @journal_1.postings << @posting_2
      @journal_1.postings << @posting_3

      @journal_2 = Journal.spawn
      @journal_2.postings << @posting_1
      @journal_2.postings << @posting_2

      @journal_3 = Journal.spawn
      @journal_3.postings << @posting_3
      @journal_3.postings << @posting_4
    end

    should "check that postings balance" do
      assert @journal_1.postings_are_balanced?
    end

    should "detect postings that do not balance" do
      assert !@journal_2.postings_are_balanced?
    end
  end

  context "validations" do
    setup do
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
    end

    should "validate postings that balance" do
      assert_nothing_raised do
        @journal = Journal.spawn
        @journal.postings << @posting_1
        @journal.postings << @posting_2
        @journal.postings << @posting_3
        @journal.save!
      end
    end

    should "do not validate postings that do not balance" do
      assert_raises(ActiveRecord::RecordInvalid, "postings do not sum to zero") do
        @journal = Journal.spawn
        @journal.postings << @posting_1
        @journal.postings << @posting_2
        @journal.save!
      end
    end
  end

  context "#all_journals class method" do
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

      @j1 = Journal.spawn(:description => "journal 1")
      @j2 = Journal.spawn(:description => "journal 2")
      @j3 = Journal.spawn(:description => "journal 3")
      @j4 = Journal.spawn(:description => "journal 4")
      @j5 = Journal.spawn(:description => "journal 5")

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

      @j1.save!
      @j2.save!
      @j3.save!
      @j4.save!
      @j5.save!

      @a1.save!
      @a2.save!
      @a3.save!
    end

    should "return all journals unfiltered" do
      assert_equal [@j1, @j2, @j3, @j4, @j5].map(&:description).to_set, Journal.all_journals.map(&:description).to_set
    end

    should "return all journals filtered" do
      assert_equal [@j1, @j3, @j4].map(&:description).to_set, Journal.all_journals(@a1.id).map(&:description).to_set
    end
  end

end
