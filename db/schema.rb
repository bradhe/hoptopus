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

ActiveRecord::Schema.define(:version => 20110328052908) do

  create_table "alerts", :force => true do |t|
    t.integer  "user_id"
    t.string   "name"
    t.boolean  "dismissed",  :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "beers", :force => true do |t|
    t.string   "name"
    t.string   "type"
    t.float    "abv"
    t.float    "price"
    t.integer  "quantity"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "cellar_id"
    t.datetime "cellared_at"
    t.string   "year"
    t.string   "bottle_size"
    t.string   "name"
    t.string   "brewery"
    t.datetime "removed_at"
    t.datetime "finish_aging_at"
  end

  create_table "cellars", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
  end

  create_table "confirmation_requests", :force => true do |t|
    t.integer  "user_id"
    t.string   "confirmation_code"
    t.boolean  "confirmed",         :default => false
    t.boolean  "expired",           :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "events", :force => true do |t|
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "source_type"
    t.integer  "source_id"
    t.string   "formatter_type"
  end

  create_table "newsletter_signups", :force => true do |t|
    t.string   "email"
    t.datetime "created_at"
    t.datetime "updated_at"
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
    t.integer  "beer_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "cellared_at"
  end

  create_table "uploaded_beer_records", :force => true do |t|
    t.string   "job_id"
    t.string   "brewery"
    t.string   "variety"
    t.string   "bottle_size"
    t.string   "quantity"
    t.string   "brew_style"
    t.string   "year"
    t.string   "cellared_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "email"
    t.string   "password_hash"
    t.string   "username"
    t.boolean  "email_consent",                      :default => false
    t.string   "country"
    t.string   "state"
    t.string   "city"
    t.boolean  "should_show_own_events",             :default => true
    t.boolean  "should_receive_email_notifications", :default => true
    t.integer  "facebook_id"
    t.datetime "last_login_at"
    t.boolean  "confirmed",                          :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end
end
