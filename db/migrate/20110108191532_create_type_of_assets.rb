class CreateTypeOfAssets < ActiveRecord::Migration
  def self.up
    create_table :type_of_assets do |t|
      t.string :name, :default => ""
      t.string :description
    end
  end

  def self.down
    drop_table :type_of_assets
  end
end
