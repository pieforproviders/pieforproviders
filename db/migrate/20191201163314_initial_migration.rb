# frozen_string_literal: true

class InitialMigration < ActiveRecord::Migration[6.0]
  def change
    enable_extension 'pgcrypto' unless extension_enabled?('pgcrypto')

    ########################################
    # Reference Data - Locations
    ########################################

    create_table :states, id: :uuid do |t|
      t.string :abbr, limit: 2, index: true
      t.string :name

      t.timestamps
    end

    create_table :counties, id: :uuid do |t|
      t.references :state, type: :uuid, null: false, foreign_key: true, index: true
      t.string :abbr
      t.string :name, index: true
      t.string :county_seat

      t.timestamps
    end

    create_table :zipcodes, id: :uuid do |t|
      t.string :code, null: false, index: { unique: true }
      t.string :city
      t.references :state, type: :uuid, null: false, foreign_key: true, index: true
      t.references :county, type: :uuid, null: false, foreign_key: true, index: true
      t.string :area_code
      t.decimal :lat, precision: 15, scale: 10
      t.decimal :lon, precision: 15, scale: 10
      t.index %i[lat lon]

      t.timestamps
    end

    ########################################
    # Reference Data - Subsidy Rules
    ########################################

    create_table :subsidy_rules, id: :uuid do |t|
      t.string :name, null: false
      t.date :effective_on
      t.date :expires_on
      t.string :license_type, null: false
      t.references :county, type: :uuid, foreign_key: true, index: true
      t.references :state, type: :uuid, null: false, foreign_key: true, index: true
      t.references :subsidy_ruleable, polymorphic: true, index: { name: :subsidy_ruleable_index }
      t.decimal :max_age, null: false

      t.timestamps
    end

    create_table :illinois_subsidy_rules, id: :uuid do |t|
      t.decimal :bronze_percentage
      t.decimal :silver_percentage
      t.decimal :gold_percentage
      t.decimal :part_day_rate
      t.decimal :full_day_rate

      t.timestamps
    end

    ########################################
    # Users & Auth
    ########################################

    create_table :users, id: :uuid do |t|
      t.boolean :active, null: false, default: true
      t.string :full_name, null: false
      t.string :greeting_name, null: false
      t.string :organization, null: false
      t.string :email, null: false, index: true, unique: true
      t.string :language, null: false
      t.string :phone_type
      t.boolean :opt_in_email, null: false, default: true
      t.boolean :opt_in_text, null: false, default: true
      t.string :phone_number, index: true, unique: true
      t.boolean :service_agreement_accepted, null: false, default: false
      t.boolean :admin, null: false, default: false
      t.string :timezone, null: false
      t.string :encrypted_password, null: false, default: ''

      ## DEVISE: Recoverable
      t.string   :reset_password_token, index: true, unique: true
      t.datetime :reset_password_sent_at

      ## DEVISE: Rememberable
      t.datetime :remember_created_at

      ## DEVISE: Trackable
      t.integer  :sign_in_count, default: 0, null: false
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.inet     :current_sign_in_ip
      t.inet     :last_sign_in_ip

      ## DEVISE: Confirmable
      t.string   :confirmation_token, index: true, unique: true
      t.datetime :confirmed_at
      t.datetime :confirmation_sent_at
      t.string   :unconfirmed_email # Only if using reconfirmable

      t.timestamps
    end

    create_table :blocked_tokens, id: :uuid do |t|
      t.string :jti, null: false, index: true
      t.datetime :expiration, null: false

      t.timestamps
    end

    ########################################
    # Businesses and Cases
    ########################################

    create_table :businesses, id: :uuid do |t|
      t.boolean :active, null: false, default: true
      t.string :license_type, null: false
      t.string :name, null: false
      t.references :user, type: :uuid, null: false, index: true, foreign_key: true
      t.references :county, type: :uuid, null: false, foreign_key: true, index: true
      t.references :zipcode, type: :uuid, null: false, foreign_key: true, index: true

      t.timestamps
    end

    create_table :children, id: :uuid do |t|
      t.boolean :active, null: false, default: true
      t.string :full_name, null: false
      t.date :date_of_birth, null: false
      t.references :business, type: :uuid, null: false, index: true, foreign_key: true

      t.timestamps

      t.index %i[full_name date_of_birth business_id], unique: true, name: :unique_children
    end

    create_table :approvals, id: :uuid do |t|
      t.string :case_number
      t.monetize :copay, amount: { null: true, default: nil }
      t.string :copay_frequency
      t.date :effective_on
      t.date :expires_on

      t.timestamps
    end

    create_table :child_approvals, id: :uuid do |t|
      t.references :subsidy_rule, type: :uuid, foreign_key: true
      t.references :approval, null: false, type: :uuid, foreign_key: true
      t.references :child, null: false, type: :uuid, foreign_key: true

      t.timestamps
    end

    ########################################
    # Attendances and Billable Occurrences
    ########################################

    create_table :billable_occurrences, id: :uuid do |t|
      t.references :billable, polymorphic: true, index: { name: :billable_index }
      t.references :child_approval, type: :uuid, foreign_key: true, null: false

      t.timestamps
    end

    create_table :attendances, id: :uuid do |t|
      t.datetime :check_in, null: false
      t.datetime :check_out, null: false
      t.interval :total_time_in_care, null: false, comment: 'Calculated: check_out time - check_in time'

      t.timestamps
    end
  end
end
