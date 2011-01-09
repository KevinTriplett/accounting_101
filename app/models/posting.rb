class Posting < ActiveRecord::Base

  belongs_to :account
  belongs_to :journal
  belongs_to :type_of_asset

  validates_numericality_of :amount
  validates_exclusion_of :amount, :in => [0]

  attr_accessible :amount, :transacted_on

  after_create :initialize_transacted_on

  scope :debit, where('amount > 0')
  scope :credit, where('amount < 0')

  def account_name
    account.name
  end

  def debit?
    amount > 0
  end

  def credit?
    amount < 0
  end

  def self.all_postings(account_id = nil)
    where(account_id ? ["account_id = ?", account_id] : nil)
  end

private

  def initialize_transacted_on
    update_attribute(:transacted_on, journal.created_at) if transacted_on.nil?
  end

end
