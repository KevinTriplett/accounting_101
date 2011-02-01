class Posting < ActiveRecord::Base
  class UpdateNotAllow < RuntimeError; end
  include AASM
  belongs_to :account
  belongs_to :journal
  belongs_to :type_of_asset

  validates_numericality_of :amount
  validates_exclusion_of :amount, :in => [0]

  attr_accessible :amount, :transacted_on

  after_create :initialize_transacted_on
  
  before_validation(:check_batch, :on => :update)

  aasm_column :state
  aasm_initial_state :uncleared

  aasm_state :uncleared
  aasm_state :cleared
  aasm_state :reconciled

  aasm_event :clear do
    transitions :to => :cleared, :from => :uncleared
  end

  aasm_event :reconcile do
    transitions :to => :reconciled, :from => :cleared
  end

  aasm_event :unclear do
    transitions :to => :uncleared, :from => :reconciled, :guard => Proc.new { |p| p.journal.batch.state != "closed"}
    transitions :to => :uncleared, :from => :cleared
  end

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

  def check_batch
    #if batch closed then not allowed for update
    if self.journal.batch.state == "closed"
      raise Posting::UpdateNotAllow
    end
  end

end
