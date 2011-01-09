class Account < ActiveRecord::Base
  class OrphanPostings < RuntimeError; end

  belongs_to :type_of_account
  belongs_to :parent, :class_name => 'Account', :foreign_key => 'account_id'
  has_many :subaccounts, :class_name => 'Account', :foreign_key => 'account_id'

  has_many :postings
  has_many :journals, :through => :postings

  validates_presence_of :name
  validates_uniqueness_of :name, :case_sensitive => false

  attr_accessible :name, :description, :number, :type_of_account, :balance, :limit, :warning

  before_destroy :cannot_orphan_postings

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
