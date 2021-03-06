class CreatePostings < ActiveRecord::Migration
  def self.up
    create_table :postings do |t|
      t.belongs_to :account, :null => false
      t.belongs_to :journal, :null => false
      t.belongs_to :type_of_asset, :null => true
      
      t.string  :state
      t.string  :memo
      t.decimal :amount, :precision => 15, :scale => 2, :default => 0
      t.decimal :conversion, :precision => 9, :scale => 2, :default => 1
      t.date    :transacted_on

      t.timestamps
    end
  end

  def self.down
    drop_table :postings
  end
end
