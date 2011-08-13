class Account < ActiveRecord::Base
  class OrphanPostings < RuntimeError; end

  belongs_to :type_of_account
  belongs_to :parent, :class_name => 'Account', :foreign_key => 'parent_id'
  has_many   :subaccounts, :class_name => 'Account', :foreign_key => 'parent_id'
  has_many   :postings
  has_many   :journals, :through => :postings

  delegate :debit, :to => :type_of_account

  validates :name, :presence => true
  validates :name, :uniqueness => {:case_sensitive => false}

  attr_accessible :name, :description, :number, :type_of_account, :balance, :limit, :warning

  before_destroy :cannot_orphan_postings

  def debit_account?
    type_of_account.debit
  end

  def credit_account?
    !type_of_account.debit
  end

  # record a transaction between accounts
  # +amount+:: the amount being entered between this accounts and a second account or
  #            (eventually) split entries creates an array of amounts, one for each secondary account
  #            and total is the sum of all amounts
  # +secondary+:: second account for double entry or
  #               (eventually) split entries creates an array of multiple secondary accounts
  # +description+:: description for journal, either new or to modify existing journal description
  # +journal+:: optional Journal reference if editing an existing Journal
  # returns Journal object, whether new or existing (mainly for specs)
  def post(amount, secondary, description, journal=nil)
    journal ||= Journal.new
    journal.description = description

    reverse = !(self.debit ^ secondary.debit)

    journal.postings << self.postings.build(:amount => amount)
    journal.postings << secondary.postings.build(:amount => (reverse ? -amount : amount))
    journal.save!
    journal
  end

  def ancestors
    parent ? ([parent] + parent.ancestors).flatten : []
  end

  def descendants
    subaccounts.size == 0 ? [] : (subaccounts + subaccounts.collect(&:descendants)).flatten
  end

  def all_postings
    descendants.inject(postings) { |collection, account| collection + account.postings }
  end

  private

  def cannot_orphan_postings
    raise Account::OrphanPostings if postings.size > 0
  end

end
