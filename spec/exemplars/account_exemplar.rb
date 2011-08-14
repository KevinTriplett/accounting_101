class Account < ActiveRecord::Base
  generator_for :name, :method => :next_name
  generator_for :type_of_account_id, 123

  def self.next_name
     @account_name ||= "Stencil Chips"
     @account_name.succ!
  end
end
