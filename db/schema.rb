# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2022_07_20_165954) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_stat_statements"
  enable_extension "pgcrypto"
  enable_extension "plpgsql"

  create_table "approvals", id: :uuid, default: -> { "public.gen_random_uuid()" }, force: :cascade do |t|
    t.string "case_number"
    t.integer "copay_cents"
    t.string "copay_currency", default: "USD", null: false
    t.string "copay_frequency"
    t.date "effective_on"
    t.date "expires_on"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.date "deleted_at"
    t.boolean "active", default: true, null: false
    t.string "inactive_reason"
    t.index ["effective_on"], name: "index_approvals_on_effective_on"
    t.index ["expires_on"], name: "index_approvals_on_expires_on"
  end

  create_table "attendances", id: :uuid, default: -> { "public.gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "check_in", null: false
    t.datetime "check_out"
    t.interval "time_in_care", null: false, comment: "Calculated: check_out time - check_in time"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.uuid "child_approval_id", null: false
    t.string "wonderschool_id"
    t.string "absence"
    t.date "deleted_at"
    t.uuid "service_day_id"
    t.index ["absence"], name: "index_attendances_on_absence"
    t.index ["check_in"], name: "index_attendances_on_check_in"
    t.index ["child_approval_id"], name: "index_attendances_on_child_approval_id"
    t.index ["service_day_id"], name: "index_attendances_on_service_day_id"
  end

  create_table "blocked_tokens", id: :uuid, default: -> { "public.gen_random_uuid()" }, force: :cascade do |t|
    t.string "jti", null: false
    t.datetime "expiration", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["jti"], name: "index_blocked_tokens_on_jti"
  end

  create_table "businesses", id: :uuid, default: -> { "public.gen_random_uuid()" }, force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.string "license_type", null: false
    t.string "name", null: false
    t.uuid "user_id", null: false
    t.string "county"
    t.string "state"
    t.string "zipcode"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "quality_rating"
    t.boolean "accredited"
    t.date "deleted_at"
    t.string "inactive_reason"
    t.index ["name", "user_id"], name: "index_businesses_on_name_and_user_id", unique: true
    t.index ["user_id"], name: "index_businesses_on_user_id"
  end

  create_table "child_approvals", id: :uuid, default: -> { "public.gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "approval_id", null: false
    t.uuid "child_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "full_days"
    t.decimal "hours"
    t.boolean "special_needs_rate"
    t.decimal "special_needs_daily_rate"
    t.decimal "special_needs_hourly_rate"
    t.boolean "enrolled_in_school"
    t.decimal "authorized_weekly_hours", precision: 5, scale: 2
    t.string "rate_type"
    t.uuid "rate_id"
    t.date "deleted_at"
    t.index ["approval_id"], name: "index_child_approvals_on_approval_id"
    t.index ["child_id"], name: "index_child_approvals_on_child_id"
    t.index ["rate_type", "rate_id"], name: "index_child_approvals_on_rate"
  end

  create_table "children", id: :uuid, default: -> { "public.gen_random_uuid()" }, force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.date "date_of_birth", null: false
    t.uuid "business_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "wonderschool_id"
    t.string "dhs_id"
    t.date "last_active_date"
    t.string "inactive_reason"
    t.date "deleted_at"
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.index ["business_id"], name: "index_children_on_business_id"
    t.index ["deleted_at"], name: "index_children_on_deleted_at"
    t.index ["first_name", "last_name", "date_of_birth", "business_id"], name: "unique_children", unique: true
  end

  create_table "data_migrations", primary_key: "version", id: :string, force: :cascade do |t|
  end

  create_table "good_job_processes", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.jsonb "state"
  end

  create_table "good_jobs", id: :uuid, default: -> { "public.gen_random_uuid()" }, force: :cascade do |t|
    t.text "queue_name"
    t.integer "priority"
    t.jsonb "serialized_params"
    t.datetime "scheduled_at"
    t.datetime "performed_at"
    t.datetime "finished_at"
    t.text "error"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.uuid "active_job_id"
    t.text "concurrency_key"
    t.text "cron_key"
    t.uuid "retried_good_job_id"
    t.datetime "cron_at"
    t.index ["active_job_id", "created_at"], name: "index_good_jobs_on_active_job_id_and_created_at"
    t.index ["active_job_id"], name: "index_good_jobs_on_active_job_id"
    t.index ["concurrency_key"], name: "index_good_jobs_on_concurrency_key_when_unfinished", where: "(finished_at IS NULL)"
    t.index ["cron_key", "created_at"], name: "index_good_jobs_on_cron_key_and_created_at"
    t.index ["cron_key", "cron_at"], name: "index_good_jobs_on_cron_key_and_cron_at", unique: true
    t.index ["finished_at"], name: "index_good_jobs_jobs_on_finished_at", where: "((retried_good_job_id IS NULL) AND (finished_at IS NOT NULL))"
    t.index ["queue_name", "scheduled_at"], name: "index_good_jobs_on_queue_name_and_scheduled_at", where: "(finished_at IS NULL)"
    t.index ["scheduled_at"], name: "index_good_jobs_on_scheduled_at", where: "(finished_at IS NULL)"
  end

  create_table "illinois_approval_amounts", id: :uuid, default: -> { "public.gen_random_uuid()" }, force: :cascade do |t|
    t.date "month", null: false
    t.integer "part_days_approved_per_week"
    t.integer "full_days_approved_per_week"
    t.uuid "child_approval_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.date "deleted_at"
    t.index ["child_approval_id"], name: "index_illinois_approval_amounts_on_child_approval_id"
  end

  create_table "illinois_rates", id: :uuid, default: -> { "public.gen_random_uuid()" }, force: :cascade do |t|
    t.decimal "bronze_percentage"
    t.decimal "silver_percentage"
    t.decimal "gold_percentage"
    t.decimal "part_day_rate"
    t.decimal "full_day_rate"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.decimal "attendance_threshold"
    t.string "county", default: " ", null: false
    t.date "effective_on", null: false
    t.date "expires_on"
    t.string "license_type", default: "licensed_family_home", null: false
    t.decimal "max_age", default: "0.0", null: false
    t.string "name", default: "Rule Name Filler", null: false
    t.date "deleted_at"
    t.index ["effective_on"], name: "index_illinois_rates_on_effective_on"
    t.index ["expires_on"], name: "index_illinois_rates_on_expires_on"
  end

  create_table "nebraska_approval_amounts", id: :uuid, default: -> { "public.gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "child_approval_id", null: false
    t.date "effective_on", null: false
    t.date "expires_on", null: false
    t.decimal "family_fee", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.date "deleted_at"
    t.index ["child_approval_id"], name: "index_nebraska_approval_amounts_on_child_approval_id"
    t.index ["effective_on"], name: "index_nebraska_approval_amounts_on_effective_on"
    t.index ["expires_on"], name: "index_nebraska_approval_amounts_on_expires_on"
  end

  create_table "nebraska_dashboard_cases", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "month", default: "2022-05-05 01:37:11", null: false
    t.string "attendance_risk", default: "not_enough_info", null: false
    t.integer "absences", default: 0, null: false
    t.integer "earned_revenue_cents"
    t.string "earned_revenue_currency", default: "USD", null: false
    t.integer "estimated_revenue_cents"
    t.string "estimated_revenue_currency", default: "USD", null: false
    t.integer "scheduled_revenue_cents"
    t.string "scheduled_revenue_currency", default: "USD", null: false
    t.integer "full_days", default: 0, null: false
    t.float "hours", default: 0.0, null: false
    t.integer "full_days_remaining", default: 0, null: false
    t.float "hours_remaining", default: 0.0, null: false
    t.float "attended_weekly_hours", default: 0.0, null: false
    t.uuid "child_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["child_id"], name: "index_nebraska_dashboard_cases_on_child_id"
    t.index ["month", "child_id"], name: "index_nebraska_dashboard_cases_on_month_and_child_id", unique: true
  end

  create_table "nebraska_rates", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "region", null: false
    t.string "rate_type", null: false
    t.decimal "amount", null: false
    t.string "county"
    t.boolean "accredited_rate", default: false
    t.date "effective_on", null: false
    t.date "expires_on"
    t.string "license_type", null: false
    t.decimal "max_age"
    t.string "name", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "school_age", default: false
    t.date "deleted_at"
    t.string "quality_rating"
    t.index ["effective_on"], name: "index_nebraska_rates_on_effective_on"
    t.index ["expires_on"], name: "index_nebraska_rates_on_expires_on"
  end

  create_table "notifications", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "child_id"
    t.uuid "approval_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["approval_id"], name: "index_notifications_on_approval_id"
    t.index ["child_id", "approval_id"], name: "index_notifications_on_child_id_and_approval_id", unique: true
    t.index ["child_id"], name: "index_notifications_on_child_id"
  end

  create_table "schedules", id: :uuid, default: -> { "public.gen_random_uuid()" }, force: :cascade do |t|
    t.date "effective_on", null: false
    t.date "expires_on"
    t.integer "weekday", null: false
    t.uuid "child_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.date "deleted_at"
    t.interval "duration"
    t.index ["child_id"], name: "index_schedules_on_child_id"
    t.index ["effective_on", "child_id", "weekday"], name: "unique_child_schedules", unique: true
    t.index ["effective_on"], name: "index_schedules_on_effective_on"
    t.index ["expires_on"], name: "index_schedules_on_expires_on"
    t.index ["updated_at"], name: "index_schedules_on_updated_at"
    t.index ["weekday"], name: "index_schedules_on_weekday"
  end

  create_table "service_days", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "date", null: false
    t.uuid "child_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.interval "total_time_in_care"
    t.integer "earned_revenue_cents"
    t.string "earned_revenue_currency", default: "USD", null: false
    t.uuid "schedule_id"
    t.string "absence_type"
    t.index ["child_id", "date"], name: "index_service_days_on_child_id_and_date", unique: true
    t.index ["child_id"], name: "index_service_days_on_child_id"
    t.index ["date"], name: "index_service_days_on_date"
    t.index ["schedule_id"], name: "index_service_days_on_schedule_id"
  end

  create_table "users", id: :uuid, default: -> { "public.gen_random_uuid()" }, force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.string "full_name", null: false
    t.string "greeting_name"
    t.string "organization"
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
    t.date "deleted_at"
    t.string "state", limit: 2
    t.text "stressed_about_billing"
    t.text "not_as_much_money"
    t.text "too_much_time"
    t.text "accept_more_subsidy_families"
    t.text "get_from_pie"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["phone_number"], name: "index_users_on_phone_number", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token"
  end

  add_foreign_key "attendances", "child_approvals"
  add_foreign_key "attendances", "service_days"
  add_foreign_key "businesses", "users"
  add_foreign_key "child_approvals", "approvals"
  add_foreign_key "child_approvals", "children"
  add_foreign_key "children", "businesses"
  add_foreign_key "illinois_approval_amounts", "child_approvals"
  add_foreign_key "nebraska_approval_amounts", "child_approvals"
  add_foreign_key "nebraska_dashboard_cases", "children"
  add_foreign_key "notifications", "approvals"
  add_foreign_key "notifications", "children"
  add_foreign_key "schedules", "children"
  add_foreign_key "service_days", "children"
  add_foreign_key "service_days", "schedules"
end
