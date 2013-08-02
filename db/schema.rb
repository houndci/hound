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

ActiveRecord::Schema.define(:version => 20130621203400) do

  create_table "builds", :force => true do |t|
    t.text     "violations"
    t.integer  "repo_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "builds", ["repo_id"], :name => "index_builds_on_repo_id"

  create_table "repos", :force => true do |t|
    t.integer "github_id",                           :null => false
    t.boolean "active",           :default => false, :null => false
    t.integer "user_id",                             :null => false
    t.integer "hook_id"
    t.string  "name",                                :null => false
    t.string  "full_github_name",                    :null => false
  end

  add_index "repos", ["user_id", "github_id"], :name => "index_repos_on_user_id_and_github_id", :unique => true

  create_table "users", :force => true do |t|
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
    t.string   "github_username", :null => false
    t.string   "remember_token",  :null => false
    t.string   "github_token"
  end

end
