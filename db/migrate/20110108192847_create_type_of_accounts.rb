class CreateTypeOfAccounts < ActiveRecord::Migration
  def self.up
    create_table :type_of_accounts do |t|
      t.string :name
      t.string :description
    end
  end

  def self.down
    drop_table :type_of_accounts
  end
end
