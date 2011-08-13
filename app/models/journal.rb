class BalancedValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    record.errors[attribute] << "must sum to zero" unless record.balanced?
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

  def balanced?
    0 == postings.inject(0) {|sum, posting| sum += posting.amount}
  end
end
