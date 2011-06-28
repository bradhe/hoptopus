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

ActiveRecord::Schema.define(:version => 20110527033045) do

  create_table "alerts", :force => true do |t|
    t.integer  "user_id"
    t.string   "name"
    t.boolean  "dismissed",  :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "beers", :force => true do |t|
    t.integer  "cellar_id"
    t.string   "name"
    t.string   "style"
    t.float    "abv"
    t.float    "price"
    t.integer  "quantity"
    t.datetime "cellared_at"
    t.string   "year"
    t.string   "bottle_size"
    t.string   "brewery"
    t.datetime "removed_at"
    t.datetime "finish_aging_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "bottle_sizes", :force => true do |t|
    t.string    "name"
    t.timestamp "created_at"
    t.timestamp "updated_at"
    t.integer   "sort_order"
  end

  create_table "brew_types", :force => true do |t|
    t.string    "name"
    t.timestamp "created_at"
    t.timestamp "updated_at"
  end

  create_table "breweries", :force => true do |t|
    t.string    "name"
    t.string    "country"
    t.string    "state"
    t.string    "city"
    t.timestamp "created_at"
    t.timestamp "updated_at"
    t.string    "sanitized_name"
  end

  create_table "brews", :force => true do |t|
    t.string    "name"
    t.integer   "brewery_id"
    t.timestamp "created_at"
    t.timestamp "updated_at"
    t.integer   "brew_type_id"
    t.integer   "ibus"
    t.float     "abv"
    t.integer   "suggested_aging_years"
    t.integer   "suggested_aging_months"
  end

  create_table "cellars", :force => true do |t|
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "comments", :force => true do |t|
    t.string    "title",            :limit => 50, :default => ""
    t.text      "comment"
    t.integer   "commentable_id"
    t.string    "commentable_type"
    t.integer   "user_id"
    t.timestamp "created_at"
    t.timestamp "updated_at"
  end

  add_index "comments", ["commentable_id"], :name => "index_comments_on_commentable_id"
  add_index "comments", ["commentable_type"], :name => "index_comments_on_commentable_type"
  add_index "comments", ["user_id"], :name => "index_comments_on_user_id"

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
    t.string   "source_type"
    t.integer  "source_id"
    t.string   "formatter_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "newsletter_signups", :force => true do |t|
    t.string   "email"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "password_reset_attempts", :force => true do |t|
    t.integer  "user_id"
    t.string   "security_token"
    t.boolean  "confirmed",      :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "roles", :force => true do |t|
    t.string    "name"
    t.timestamp "created_at"
    t.timestamp "updated_at"
  end

  create_table "roles_users", :id => false, :force => true do |t|
    t.integer   "role_id"
    t.integer   "user_id"
    t.timestamp "created_at"
    t.timestamp "updated_at"
  end

  create_table "tasting_notes", :force => true do |t|
    t.integer  "beer_id"
    t.integer  "pour_rating",         :default => 0
    t.integer  "aroma_rating",        :default => 0
    t.integer  "taste_rating",        :default => 0
    t.integer  "appearance_rating",   :default => 0
    t.integer  "mouthfeel_rating",    :default => 0
    t.integer  "drinkability_rating", :default => 0
    t.integer  "preference_rating",   :default => 0
    t.text     "notes"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tastings", :force => true do |t|
    t.integer   "user_id"
    t.timestamp "created_at"
    t.timestamp "updated_at"
    t.integer   "brew_id"
    t.timestamp "cellared_at"
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
    t.boolean  "admin",                              :default => false
    t.boolean  "should_show_own_events",             :default => true
    t.boolean  "should_receive_email_notifications", :default => true
    t.integer  "facebook_id"
    t.datetime "last_login_at"
    t.boolean  "confirmed",                          :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "wikis", :force => true do |t|
    t.integer   "for_id"
    t.string    "for_type"
    t.text      "markup"
    t.integer   "revision"
    t.timestamp "created_at"
    t.timestamp "updated_at"
  end

end
