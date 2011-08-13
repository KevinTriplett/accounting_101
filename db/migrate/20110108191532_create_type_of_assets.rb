class TypeOfAsset < ActiveRecord::Base; end

class CreateTypeOfAssets < ActiveRecord::Migration
  def self.up
    create_table :type_of_assets do |t|
      t.string :name, :default => ""
      t.decimal :conversion, :precision => 9, :scale => 2
    end
  end

  def self.down
    drop_table :type_of_assets
  end
end
