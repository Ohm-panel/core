# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20100219230544) do

  create_table "domains", :force => true do |t|
    t.string   "domain"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "domains_services", :id => false, :force => true do |t|
    t.integer "domain_id"
    t.integer "service_id"
  end

  create_table "service_email_mailboxes", :force => true do |t|
    t.string   "address"
    t.integer  "domain_id"
    t.string   "full_name"
    t.integer  "size"
    t.string   "password"
    t.text     "forward"
    t.boolean  "forward_only"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "services", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "by_domain"
    t.string   "controller"
    t.string   "tech_name"
  end

  create_table "services_users", :id => false, :force => true do |t|
    t.integer "user_id"
    t.integer "service_id"
  end

  create_table "subdomains", :force => true do |t|
    t.string   "url"
    t.string   "path"
    t.boolean  "mainsub"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "domain_id"
  end

  create_table "users", :force => true do |t|
    t.string   "username"
    t.string   "password"
    t.string   "full_name"
    t.string   "email"
    t.integer  "parent_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "session"
    t.datetime "session_ts"
    t.integer  "max_subdomains"
    t.integer  "max_space"
    t.integer  "max_bandwidth"
    t.integer  "max_subusers"
    t.integer  "used_space"
  end

end
