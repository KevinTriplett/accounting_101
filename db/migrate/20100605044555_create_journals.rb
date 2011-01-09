class CreateJournals < ActiveRecord::Migration
  def self.up
    create_table :journals do |t|
      t.belongs_to :batch, :null => true

      t.string :description, :default => ""
      t.string :memo

      t.timestamps
    end
  end

  def self.down
    drop_table :journals
  end
end
