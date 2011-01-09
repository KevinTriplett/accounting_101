class Posting < ActiveRecord::Base
  generator_for :amount, 100
  generator_for :transacted_on, Time.now
  generator_for :account_id, 333
  generator_for :journal_id, 222
  generator_for :type_of_asset_id, 1
end
