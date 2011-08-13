class TypeOfAccount < ActiveRecord::Base; end

class CreateTypeOfAccounts < ActiveRecord::Migration
  def self.up
    create_table :type_of_accounts do |t|
      t.string :name, :default => ""
      t.boolean :debit, :default => true
    end

    debit_types = %w{asset draw expense}
    credit_types = %w{liability capital retained_earnings equity contribution revenue}

    (debit_types + credit_types).each do |name|
      debit = debit_types.include? name
      TypeOfAccount.create!(:name => name, :debit => debit)
    end
  end

  def self.down
    drop_table :type_of_accounts
  end
end
