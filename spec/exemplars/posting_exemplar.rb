class Posting < ActiveRecord::Base
  generator_for :amount, 100
  generator_for :transacted_on, nil
  generator_for :account_id, 333
  generator_for :journal_id, 222
end
