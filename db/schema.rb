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

ActiveRecord::Schema.define(version: 20170505220736) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "pg_stat_statements"

  create_table "blacklisted_pull_requests", force: :cascade do |t|
    t.string   "full_repo_name",      null: false
    t.integer  "pull_request_number", null: false
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
  end

  create_table "builds", force: :cascade do |t|
    t.text     "violations_archive"
    t.integer  "repo_id"
    t.datetime "created_at",                                  null: false
    t.datetime "updated_at",                                  null: false
    t.string   "uuid",                limit: 255,             null: false
    t.integer  "pull_request_number"
    t.string   "commit_sha",          limit: 255
    t.text     "payload"
    t.integer  "user_id"
    t.integer  "violations_count",                default: 0, null: false
  end

  add_index "builds", ["commit_sha", "pull_request_number"], name: "index_builds_on_commit_sha_and_pull_request_number", using: :btree
  add_index "builds", ["repo_id"], name: "index_builds_on_repo_id", using: :btree
  add_index "builds", ["uuid"], name: "index_builds_on_uuid", unique: true, using: :btree

  create_table "bulk_customers", force: :cascade do |t|
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.string   "org",                            null: false
    t.string   "description"
    t.string   "interval",                       null: false
    t.integer  "repo_limit"
    t.integer  "current_repos",      default: 0, null: false
    t.string   "subscription_token"
  end

  add_index "bulk_customers", ["org"], name: "index_bulk_customers_on_org", unique: true, using: :btree

  create_table "file_reviews", force: :cascade do |t|
    t.integer  "build_id",     null: false
    t.datetime "completed_at"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.string   "filename",     null: false
    t.string   "linter_name",  null: false
    t.string   "error"
  end

  add_index "file_reviews", ["build_id"], name: "index_file_reviews_on_build_id", using: :btree

  create_table "memberships", force: :cascade do |t|
    t.integer  "user_id",                    null: false
    t.integer  "repo_id",                    null: false
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.boolean  "admin",      default: false, null: false
  end

  add_index "memberships", ["repo_id"], name: "index_memberships_on_repo_id", using: :btree
  add_index "memberships", ["user_id", "repo_id"], name: "index_memberships_on_user_id_and_repo_id", unique: true, using: :btree

  create_table "owners", force: :cascade do |t|
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.integer  "github_id",                      null: false
    t.string   "name",                           null: false
    t.boolean  "organization",   default: false, null: false
    t.boolean  "config_enabled", default: false, null: false
    t.string   "config_repo"
  end

  add_index "owners", ["github_id"], name: "index_owners_on_github_id", unique: true, using: :btree
  add_index "owners", ["name"], name: "index_owners_on_name", unique: true, using: :btree

  create_table "repos", force: :cascade do |t|
    t.integer  "github_id",                                   null: false
    t.boolean  "active",                      default: false, null: false
    t.integer  "hook_id"
    t.string   "name",            limit: 255,                 null: false
    t.datetime "created_at",                                  null: false
    t.datetime "updated_at",                                  null: false
    t.boolean  "private"
    t.boolean  "in_organization"
    t.integer  "owner_id"
  end

  add_index "repos", ["active"], name: "index_repos_on_active", using: :btree
  add_index "repos", ["github_id"], name: "index_repos_on_github_id", unique: true, using: :btree
  add_index "repos", ["name"], name: "index_repos_on_name", using: :btree
  add_index "repos", ["owner_id"], name: "index_repos_on_owner_id", using: :btree

  create_table "subscriptions", force: :cascade do |t|
    t.datetime "created_at",                                                               null: false
    t.datetime "updated_at",                                                               null: false
    t.integer  "user_id",                                                                  null: false
    t.integer  "repo_id",                                                                  null: false
    t.string   "stripe_subscription_id", limit: 255,                                       null: false
    t.datetime "deleted_at"
    t.decimal  "price",                              precision: 8, scale: 2, default: 0.0, null: false
  end

  add_index "subscriptions", ["repo_id"], name: "index_subscriptions_on_repo_id", unique: true, where: "(deleted_at IS NULL)", using: :btree
  add_index "subscriptions", ["user_id"], name: "index_subscriptions_on_user_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.datetime "created_at",                                     null: false
    t.datetime "updated_at",                                     null: false
    t.string   "username",           limit: 255,                 null: false
    t.string   "remember_token",     limit: 255,                 null: false
    t.boolean  "refreshing_repos",               default: false
    t.string   "email",              limit: 255
    t.string   "stripe_customer_id", limit: 255
    t.string   "token"
    t.string   "utm_source"
    t.string   "token_scopes"
  end

  add_index "users", ["remember_token"], name: "index_users_on_remember_token", using: :btree

  create_table "violations", force: :cascade do |t|
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.integer  "patch_position"
    t.integer  "line_number"
    t.text     "messages",       default: [], null: false, array: true
    t.integer  "file_review_id",              null: false
  end

  add_index "violations", ["file_review_id"], name: "index_violations_on_file_review_id", using: :btree

  add_foreign_key "file_reviews", "builds"
  add_foreign_key "memberships", "repos"
  add_foreign_key "memberships", "users"
  add_foreign_key "repos", "owners"
  add_foreign_key "violations", "file_reviews", on_delete: :cascade
end
