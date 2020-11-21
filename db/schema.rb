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

ActiveRecord::Schema.define(version: 2019_12_01_163314) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"

  create_table "approvals", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "case_number"
    t.integer "copay_cents"
    t.string "copay_currency", default: "USD", null: false
    t.string "copay_frequency"
    t.date "effective_on"
    t.date "expires_on"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "attendances", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "check_in", null: false
    t.datetime "check_out", null: false
    t.interval "total_time_in_care", null: false, comment: "Calculated: check_out time - check_in time"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "billable_occurrences", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "billable_type"
    t.uuid "billable_id"
    t.uuid "child_approval_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["billable_type", "billable_id"], name: "billable_index"
    t.index ["child_approval_id"], name: "index_billable_occurrences_on_child_approval_id"
  end

  create_table "blocked_tokens", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "jti", null: false
    t.datetime "expiration", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["jti"], name: "index_blocked_tokens_on_jti"
  end

  create_table "businesses", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.string "license_type", null: false
    t.string "name", null: false
    t.uuid "user_id", null: false
    t.uuid "county_id", null: false
    t.uuid "zipcode_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["county_id"], name: "index_businesses_on_county_id"
    t.index ["name", "user_id"], name: "index_businesses_on_name_and_user_id", unique: true
    t.index ["user_id"], name: "index_businesses_on_user_id"
    t.index ["zipcode_id"], name: "index_businesses_on_zipcode_id"
  end

  create_table "child_approvals", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "subsidy_rule_id"
    t.uuid "approval_id", null: false
    t.uuid "child_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["approval_id"], name: "index_child_approvals_on_approval_id"
    t.index ["child_id"], name: "index_child_approvals_on_child_id"
    t.index ["subsidy_rule_id"], name: "index_child_approvals_on_subsidy_rule_id"
  end

  create_table "children", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.string "full_name", null: false
    t.date "date_of_birth", null: false
    t.uuid "business_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["business_id"], name: "index_children_on_business_id"
    t.index ["full_name", "date_of_birth", "business_id"], name: "unique_children", unique: true
  end

  create_table "counties", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "state_id", null: false
    t.string "abbr"
    t.string "name"
    t.string "county_seat"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["abbr", "state_id"], name: "index_counties_on_abbr_and_state_id", unique: true
    t.index ["name", "state_id"], name: "index_counties_on_name_and_state_id", unique: true
    t.index ["name"], name: "index_counties_on_name"
    t.index ["state_id"], name: "index_counties_on_state_id"
  end

  create_table "illinois_subsidy_rules", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.decimal "bronze_percentage"
    t.decimal "silver_percentage"
    t.decimal "gold_percentage"
    t.decimal "part_day_rate"
    t.decimal "full_day_rate"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "states", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "abbr", limit: 2
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["abbr"], name: "index_states_on_abbr", unique: true
    t.index ["name"], name: "index_states_on_name", unique: true
  end

  create_table "subsidy_rules", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.date "effective_on"
    t.date "expires_on"
    t.string "license_type", null: false
    t.uuid "county_id"
    t.uuid "state_id", null: false
    t.string "subsidy_ruleable_type"
    t.bigint "subsidy_ruleable_id"
    t.decimal "max_age", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["county_id"], name: "index_subsidy_rules_on_county_id"
    t.index ["state_id"], name: "index_subsidy_rules_on_state_id"
    t.index ["subsidy_ruleable_type", "subsidy_ruleable_id"], name: "subsidy_ruleable_index"
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.string "full_name", null: false
    t.string "greeting_name", null: false
    t.string "organization", null: false
    t.string "email", null: false
    t.string "language", null: false
    t.string "phone_type"
    t.boolean "opt_in_email", default: true, null: false
    t.boolean "opt_in_text", default: true, null: false
    t.string "phone_number"
    t.boolean "service_agreement_accepted", default: false, null: false
    t.boolean "admin", default: false, null: false
    t.string "timezone", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["phone_number"], name: "index_users_on_phone_number", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token"
  end

  create_table "zipcodes", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "code", null: false
    t.string "city"
    t.uuid "state_id", null: false
    t.uuid "county_id", null: false
    t.string "area_code"
    t.decimal "lat", precision: 15, scale: 10
    t.decimal "lon", precision: 15, scale: 10
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["code"], name: "index_zipcodes_on_code", unique: true
    t.index ["county_id"], name: "index_zipcodes_on_county_id"
    t.index ["lat", "lon"], name: "index_zipcodes_on_lat_and_lon"
    t.index ["state_id"], name: "index_zipcodes_on_state_id"
  end

  add_foreign_key "billable_occurrences", "child_approvals"
  add_foreign_key "businesses", "counties"
  add_foreign_key "businesses", "users"
  add_foreign_key "businesses", "zipcodes"
  add_foreign_key "child_approvals", "approvals"
  add_foreign_key "child_approvals", "children"
  add_foreign_key "child_approvals", "subsidy_rules"
  add_foreign_key "children", "businesses"
  add_foreign_key "counties", "states"
  add_foreign_key "subsidy_rules", "counties"
  add_foreign_key "subsidy_rules", "states"
  add_foreign_key "zipcodes", "counties"
  add_foreign_key "zipcodes", "states"
end
