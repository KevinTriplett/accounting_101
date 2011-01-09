class CreateAccounts < ActiveRecord::Migration
  def self.up
    create_table :accounts do |t|
      t.belongs_to :account, :null => true
      t.belongs_to :type_of_account, :null => false

      t.integer :number
      t.string  :name, :default => ""
      t.string  :description

      t.timestamps
    end
  end

  def self.down
    drop_table :accounts
  end
end
