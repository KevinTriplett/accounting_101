require 'ruby-debug'

class Posting < ActiveRecord::Base

  include AASM

  belongs_to :account
  belongs_to :journal
  belongs_to :type_of_asset

  validates_numericality_of :amount
  validates_exclusion_of :amount, :in => [0]

  # attr_accessible :amount, :transacted_on, :type_of_asset_id, :account_id, :journal_id

  around_create :initialize_transacted_on_and_conversion
  
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
    transitions :to => :uncleared, :from => :reconciled
    transitions :to => :uncleared, :from => :cleared
  end

  def account_name
    account.name
  end

  def amount
    (conversion * read_attribute(:amount)).round(2)
  end

private

  def initialize_transacted_on_and_conversion
    self.conversion = type_of_asset.conversion unless type_of_asset_id.nil?
    yield
    update_attribute(:transacted_on, created_at) if transacted_on.nil?
  end
end
