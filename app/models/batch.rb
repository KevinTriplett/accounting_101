class Batch < ActiveRecord::Base
  has_many :journals

  include AASM

  aasm_column :state
  aasm_initial_state :opened

  aasm_state :opened
  aasm_state :closed, :enter => :do_close
  aasm_state :reopened

  aasm_event :reopen do
    transitions :to => :reopened, :from => :closed
  end   

  aasm_event :close do
    transitions :to => :closed, :from => [:opened,:reopened]
  end

  def do_close
    self.journals.each do |journal|
      journal.postings.each do |posting|
        posting.state = "cleared"
        posting.save
      end
    end
  end
end
