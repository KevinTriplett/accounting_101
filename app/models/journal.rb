class Journal < ActiveRecord::Base

  has_many :postings
  has_many :accounts, :through => :postings
  belongs_to :batch

  validates_presence_of :description
  validates_associated :postings

  # TODO: validate postings are balanced
  class BalancedValidator < ActiveModel::EachValidator
    def validate_each(record, attribute, value)
      record.errors[attribute] << "must sum to zero" unless record.postings_are_balanced?
    end
  end

  validates :postings, :balanced => true

  attr_accessible :description, :memo

  def postings_are_balanced?
    0 == postings.inject(0) {|sum, posting| sum += posting.amount}
  end

  def self.all_journals(account_id = nil)
    # TODO: why is the :joins clause necessary here? shouldn't it be automatic with the :conditions clause?
    joins(:postings).where(account_id ? ["postings.account_id = ?", account_id] : nil)
  end

end
