# encoding: UTF-8
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

ActiveRecord::Schema.define(:version => 20130817230738) do

  create_table "components", :force => true do |t|
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.string   "name"
  end

  create_table "data", :force => true do |t|
    t.integer  "component_id"
    t.float    "value"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  add_index "data", ["component_id"], :name => "index_data_on_component_id"

  create_table "logs", :force => true do |t|
    t.string   "type"
    t.integer  "component_id"
    t.string   "message"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  add_index "logs", ["component_id"], :name => "index_logs_on_component_id"

  create_table "messages", :force => true do |t|
    t.integer  "component_id"
    t.string   "text"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  add_index "messages", ["component_id"], :name => "index_messages_on_component_id"

end
