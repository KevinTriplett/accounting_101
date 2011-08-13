class TypeOfAccount < ActiveRecord::Base
  generator_for :name, :method => :next_name
  generator_for :debit, true

  def self.next_name
     @account_name ||= "Account Skirmish"
     @account_name.succ!
  end
end
