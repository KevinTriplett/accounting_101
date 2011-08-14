class BalancedValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    record.errors[attribute] << "must balance (sum to zero)" unless record.balanced?
  end
end

class Journal < ActiveRecord::Base

  has_many :postings, :autosave => true

  validates :description, :presence => true
  validates_associated :postings
  validates :postings, :balanced => true

  attr_accessible :description

  accepts_nested_attributes_for :postings, :allow_destroy => true, :reject_if => proc {|attrs| attrs['amount'].blank?}

  def journal(desc, posts)
    journal = Journal.new(:description => desc)
    posts.each do |post|
      journal.postings.build(:amount => post.amount, :memo => post.memo, :account_id => post.account_id)
    end
    journal.save!
  end

  def postings_with_account_type
    postings
      .joins('INNER JOIN accounts ON accounts.id = postings.account_id')
      .joins('INNER JOIN type_of_accounts ON type_of_accounts.id = accounts.type_of_account_id')
  end

  def debit_accounts_total
    postings_with_account_type
      .where('type_of_accounts.debit <> 0')
      .sum('postings.amount')
  end

  def credit_accounts_total
    postings_with_account_type
      .where('type_of_accounts.debit = 0')
      .sum('postings.amount')
  end

  def balanced?
    debit_accounts_total == credit_accounts_total
  end
end
