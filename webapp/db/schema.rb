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

ActiveRecord::Schema.define(:version => 9001) do

  create_table "configurations", :force => true do |t|
    t.boolean  "enable_www"
    t.boolean  "enable_dns"
    t.boolean  "enable_ssh"
    t.string   "ip_address"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "dns_entries", :force => true do |t|
    t.integer  "domain_id"
    t.string   "line"
    t.boolean  "add_ip"
    t.string   "creator"
    t.string   "creator_data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

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

  create_table "log_files", :force => true do |t|
    t.string   "name"
    t.string   "path"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "logged_users", :force => true do |t|
    t.string   "session"
    t.datetime "session_ts"
    t.string   "ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
  end

  create_table "services", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "by_domain"
    t.string   "controller"
    t.string   "tech_name"
    t.boolean  "daemon_installed", :default => false
    t.string   "install_files"
    t.boolean  "deleted",          :default => false
    t.string   "migrations"
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
    t.integer  "max_subdomains"
    t.integer  "max_space"
    t.integer  "max_bandwidth"
    t.integer  "max_subusers"
    t.integer  "used_space"
    t.string   "ohmd_password"
  end

end
