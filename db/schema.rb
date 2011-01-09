# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20110108192847) do

  create_table "accounts", :force => true do |t|
    t.integer  "account_id"
    t.integer  "type_of_account_id",                 :null => false
    t.integer  "number"
    t.string   "name",               :default => ""
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "batches", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "journals", :force => true do |t|
    t.integer  "batch_id"
    t.string   "description", :default => ""
    t.string   "memo"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "postings", :force => true do |t|
    t.integer  "account_id",                                                       :null => false
    t.integer  "journal_id",                                                       :null => false
    t.integer  "type_of_asset_id",                                                 :null => false
    t.string   "memo"
    t.decimal  "amount",           :precision => 15, :scale => 2, :default => 0.0
    t.date     "transacted_on"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "type_of_accounts", :force => true do |t|
    t.string "name"
    t.string "description"
  end

  create_table "type_of_assets", :force => true do |t|
    t.string "name",        :default => ""
    t.string "description"
  end

end
