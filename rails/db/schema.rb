# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_01_11_223509) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"

  create_table "children", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "full_name"
    t.string "greeting_name"
    t.date "date_of_birth"
    t.boolean "active", default: true
  end

  create_table "data_migrations", primary_key: "version", id: :string, force: :cascade do |t|
  end

  create_table "user_children", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id", null: false
    t.uuid "child_id", null: false
    t.string "relationship"
    t.index ["child_id"], name: "index_user_children_on_child_id"
    t.index ["user_id"], name: "index_user_children_on_user_id"
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.boolean "active", default: true
    t.string "county"
    t.date "date_of_birth"
    t.string "email"
    t.string "full_name"
    t.string "greeting_name"
    t.string "language"
    t.boolean "okay_to_text", default: true
    t.boolean "okay_to_email", default: true
    t.boolean "okay_to_phone", default: true
    t.boolean "opt_in_text", default: true
    t.boolean "opt_in_email", default: true
    t.boolean "opt_in_phone", default: true
    t.string "phone"
    t.boolean "service_agreement_accepted", default: true
    t.string "timezone"
    t.string "zip"
  end

  add_foreign_key "user_children", "children"
  add_foreign_key "user_children", "users"
end
