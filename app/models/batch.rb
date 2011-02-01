class Batch < ActiveRecord::Base
  has_many :journals

  include AASM

  aasm_column :state
  aasm_initial_state :opened

  aasm_state :opened
  aasm_state :closed
  aasm_state :reopened

  aasm_event :reopen do
    transitions :to => :reopened, :from => :closed
  end   

  aasm_event :close do
    transitions :to => :closed, :from => [:opened,:reopened]
  end
end
