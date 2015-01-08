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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20150108003045) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "builds", force: :cascade do |t|
    t.text     "violations_archive"
    t.integer  "repo_id"
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.string   "uuid",                limit: 255, null: false
    t.integer  "pull_request_number"
    t.string   "commit_sha",          limit: 255
  end

  add_index "builds", ["repo_id"], name: "index_builds_on_repo_id", using: :btree
  add_index "builds", ["uuid"], name: "index_builds_on_uuid", unique: true, using: :btree

  create_table "memberships", force: :cascade do |t|
    t.integer  "user_id",    null: false
    t.integer  "repo_id",    null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "memberships", ["repo_id", "user_id"], name: "index_memberships_on_repo_id_and_user_id", using: :btree

  create_table "repos", force: :cascade do |t|
    t.integer  "github_id",                                    null: false
    t.boolean  "active",                       default: false, null: false
    t.integer  "hook_id"
    t.string   "full_github_name", limit: 255,                 null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "private"
    t.boolean  "in_organization"
  end

  add_index "repos", ["active"], name: "index_repos_on_active", using: :btree
  add_index "repos", ["full_github_name"], name: "index_repos_on_full_github_name", unique: true, using: :btree
  add_index "repos", ["github_id"], name: "index_repos_on_github_id", using: :btree

  create_table "subscriptions", force: :cascade do |t|
    t.datetime "created_at",                                                               null: false
    t.datetime "updated_at",                                                               null: false
    t.integer  "user_id",                                                                  null: false
    t.integer  "repo_id",                                                                  null: false
    t.string   "stripe_subscription_id", limit: 255,                                       null: false
    t.datetime "deleted_at"
    t.decimal  "price",                              precision: 8, scale: 2, default: 0.0, null: false
  end

  add_index "subscriptions", ["repo_id"], name: "index_subscriptions_on_repo_id", using: :btree
  add_index "subscriptions", ["user_id"], name: "index_subscriptions_on_user_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.datetime "created_at",                                     null: false
    t.datetime "updated_at",                                     null: false
    t.string   "github_username",    limit: 255,                 null: false
    t.string   "remember_token",     limit: 255,                 null: false
    t.boolean  "refreshing_repos",               default: false
    t.string   "email_address",      limit: 255
    t.string   "stripe_customer_id", limit: 255
  end

  add_index "users", ["remember_token"], name: "index_users_on_remember_token", using: :btree

  create_table "violations", force: :cascade do |t|
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
    t.integer  "build_id",                                null: false
    t.string   "filename",       limit: 255,              null: false
    t.integer  "patch_position"
    t.integer  "line_number"
    t.text     "messages",                   default: [], null: false, array: true
  end

  add_index "violations", ["build_id"], name: "index_violations_on_build_id", using: :btree

end
