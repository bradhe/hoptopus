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

ActiveRecord::Schema.define(:version => 20110127190300) do

  create_table "beers", :force => true do |t|
    t.integer  "brew_id"
    t.float    "abv"
    t.float    "price"
    t.integer  "quantity"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "cellar_id"
    t.datetime "cellared_at"
    t.string   "year"
    t.integer  "bottle_size_id"
    t.text     "notes",          :limit => 255
    t.string   "name"
    t.string   "brewery_name"
    t.datetime "removed_at"
  end

  create_table "bottle_sizes", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "brew_types", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "breweries", :force => true do |t|
    t.string   "name"
    t.string   "country"
    t.string   "state"
    t.string   "city"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "brews", :force => true do |t|
    t.string   "name"
    t.integer  "brewery_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "brew_type_id"
    t.integer  "ibus"
    t.float    "abv"
    t.text     "description",  :limit => 255
  end

  create_table "cellars", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
  end

  create_table "comments", :force => true do |t|
    t.string   "title",            :limit => 50, :default => ""
    t.text     "comment"
    t.integer  "commentable_id"
    t.string   "commentable_type"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "comments", ["commentable_id"], :name => "index_comments_on_commentable_id"
  add_index "comments", ["commentable_type"], :name => "index_comments_on_commentable_type"
  add_index "comments", ["user_id"], :name => "index_comments_on_user_id"

  create_table "events", :force => true do |t|
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "source_type"
    t.integer  "source_id"
    t.string   "formatter_type"
  end

  create_table "password_reset_attempts", :force => true do |t|
    t.integer  "user_id"
    t.string   "security_token"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "confirmed",      :default => false
  end

  create_table "tastings", :force => true do |t|
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "notes",       :limit => 255
    t.integer  "brew_id"
    t.datetime "cellared_at"
  end

  create_table "users", :force => true do |t|
    t.string   "email"
    t.string   "password_hash"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "username"
    t.boolean  "email_consent",                      :default => false
    t.string   "country"
    t.string   "state"
    t.string   "city"
    t.boolean  "should_show_own_events",             :default => true
    t.boolean  "should_receive_email_notifications", :default => true
  end

end
