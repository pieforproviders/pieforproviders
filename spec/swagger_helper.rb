# frozen_string_literal: true

require 'rails_helper'

RSpec.configure do |config|
  # Specify a root folder where Swagger JSON files are generated
  # NOTE: If you're using the rswag-api to serve API descriptions, you'll need
  # to ensure that it's configured to serve Swagger from the same folder
  config.swagger_root = Rails.root.join('swagger').to_s

  # Define one or more Swagger documents and provide global metadata for each one
  # When you run the 'rswag:specs:swaggerize' rake task, the complete Swagger will
  # be generated at the provided relative path under swagger_root
  # By default, the operations defined in spec files are added to the first
  # document below. You can override this behavior by adding a swagger_doc tag to the
  # the root example_group in your specs, e.g. describe '...', swagger_doc: 'v2/swagger.json'
  config.swagger_docs = {
    'v1/swagger.json' => {
      openapi: '3.0.3',
      info: {
        title: 'Pie for Providers API v1',
        version: 'v1'
      },
      paths: {},
      # securityDefinitions: {
      #   token: {
      #     type: :oauth2,
      #     in: :header,
      #     name: 'Authorization',
      #     flow: 'password',
      #     tokenUrl: '/oauth/token',
      #     scopes: {}
      #   }
      # },
      components: {
        schemas: {
          user: {
            type: :object,
            properties: {
              email: { type: :string, example: 'user@user.com' },
              password: { type: :string, example: 'badPassword123!' },
              full_name: { type: :string, example: 'Marlee Matlin' },
              greeting_name: { type: :string, example: 'Marlee' },
              language: { type: :string, example: 'Farsi' },
              organization: { type: :string, example: 'Society for the Promotion of Elfish Welfare' },
              phone_number: { type: :string, example: '888-888-8888' },
              service_agreement_accepted: { type: :boolean, example: 'true' },
              timezone: { type: :string, example: 'Eastern Time (US & Canada)' }
            }
          },
          case_statuses: {
            type: :string,
            enum: %w[submitted
                     pending
                     approved
                     denied],
            example: 'submitted'
          },
          copay_frequencies: {
            type: :string,
            enum: %w[daily
                     weekly
                     monthly],
            example: 'weekly'
          },
          currency_or_null: {
            anyOf: [
              { type: :string, example: 'USD' },
              { type: :null }
            ]
          },
          date_or_null: {
            anyOf: [
              { type: :string, example: '2019-06-27' },
              { type: :null }
            ]
          },
          duration_definitions: {
            type: :string,
            enum: %w[part_day
                     full_day
                     full_plus_part_day
                     full_plus_full_day],
            example: 'full_day'
          },
          license_types: {
            type: :string,
            enum: %w[licensed_center
                     licensed_family_home
                     licensed_group_home
                     license_exempt_home
                     license_exempt_center],
            example: 'license_exempt_home'
          },
          time_or_null: {
            anyOf: [
              { type: :string, example: '020-09-13 14:07:47 -0700' },
              { type: :null }
            ]
          },
          business: {
            type: :object,
            properties: {
              name: { type: :string, example: 'Harlequin Child Care' },
              license_type: { '$ref': '#/components/schemas/license_types' },
              active: { type: :boolean, example: 'true' }
            }
          },
          child: {
            type: :object,
            properties: {
              ccms_id: { type: :string, example: '987654321' },
              date_of_birth: { type: :string, example: '1992-11-01' },
              full_name: { type: :string, example: 'Sean Flannery' }
            }
          },
          subsidy_rule: {
            type: :object,
            properties: {
              name: { type: :string, example: 'Rule 1' },
              max_age: { type: :number, example: 18 },
              part_day_rate_cents: { type: :integer, minimum: 0, example: 2_500 },
              part_day_rate_currency: { type: :string, example: 'USD' },
              full_day_rate_cents: { type: :integer, minimum: 0, example: 3_000 },
              full_day_rate_currency: { type: :string, example: 'USD' },
              part_day_max_hours: { type: :number, example: 4 },
              full_day_max_hours: { type: :number, example: 12 },
              full_plus_part_day_max_hours: { type: :number, example: 18 },
              full_plus_full_day_max_hours: { type: :number, example: 24 },
              part_day_threshold: { type: :number, example: 12 },
              full_day_threshold: { type: :number, example: 24 },
              license_type: { '$ref': '#/components/schemas/license_types' },
              qris_rating: { type: :string, example: '1' }
            }
          },
          case_cycle: {
            type: :object,
            properties: {
              case_number: {
                anyOf: [
                  { type: :string, example: '123-45' },
                  { type: :null }
                ]
              },
              copay_cents: { type: :integer, minimum: 0 },
              copay_currency: { type: :string, example: 'USD' },
              copay_frequency: {
                anyOf: [
                  { '$ref': '#/components/schemas/copay_frequencies' },
                  { type: :null }
                ]
              },
              effective_on: { '$ref': '#/components/schemas/date_or_null' },
              expires_on: { '$ref': '#/components/schemas/date_or_null' },
              notified_on: { '$ref': '#/components/schemas/date_or_null' },
              status: { '$ref': '#/components/schemas/case_statuses' },
              submitted_on: { type: :string, example: '2020-07-12' },
              user_id: { type: :uuid, example: '3fa57706-f5bb-4d40-9350-85871f698d52' }
            }
          },
          child_case_cycle: {
            type: :object,
            properties: {
              case_cycle_id: { type: :uuid, example: '3fa57706-f5bb-4d40-9350-85871f698d52' },
              child_id: { type: :uuid, example: '3fa57706-f5bb-4d40-9350-85871f698d52' },
              full_days_allowed: { type: :integer, example: 21 },
              part_days_allowed: { type: :integer, example: 18 },
              subsidy_rule_id: { type: :uuid, example: '3fa57706-f5bb-4d40-9350-85871f698d52' },
              user_id: { type: :uuid, example: '3fa57706-f5bb-4d40-9350-85871f698d52' }
            }
          },
          attendance: {
            type: :object,
            properties: {
              check_in: { type: :string, example: '020-09-13 14:07:47 -0700' },
              check_out: { '$ref': '#/components/schemas/time_or_null' },
              child_case_cycle_id: { type: :uuid, example: '3fa57706-f5bb-4d40-9350-85871f698d52' },
              attendance_duration: { '$ref': '#/components/schemas/duration_definitions' },
              total_time_in_care: { type: :string, example: '360 minutes' },
              starts_on: { type: :string, example: '2020-07-12' }
            }
          },
          createUser: {
            type: :object,
            properties: {
              user: {
                allOf: [
                  { '$ref': '#/components/schemas/user' },
                  {
                    type: :object,
                    required: %w[
                      email
                      full_name
                      language
                      password
                      password_confirmation
                      service_agreement_accepted
                      timezone
                    ]
                  }
                ]
              }
            }
          },
          updateUser: {
            type: :object,
            properties: {
              user: {
                allOf: [
                  { '$ref': '#/components/schemas/user' }
                ]
              }
            }
          },
          createBusiness: {
            type: :object,
            properties: {
              business: {
                allOf: [
                  { '$ref': '#/components/schemas/business' },
                  {
                    type: :object,
                    required: %w[
                      name
                      license_type
                      user_id
                    ]
                  }
                ]
              }
            }
          },
          updateBusiness: {
            type: :object,
            properties: {
              business: {
                allOf: [
                  { '$ref': '#/components/schemas/business' }
                ]
              }
            }
          },
          createChild: {
            type: :object,
            properties: {
              child: {
                type: :object,
                properties: {
                  ccms_id: { type: :string, example: '123456789' },
                  date_of_birth: { type: :string, example: '1991-11-01' },
                  full_name: { type: :string, example: 'Seamus Finnigan' },
                  user_id: { type: :uuid, example: '3fa57706-f5bb-4d40-9350-85871f698d55' }
                },
                required: %w[
                  full_name
                  date_of_birth
                  user_id
                ]
              }
            }
          },
          updateChild: {
            type: :object,
            properties: {
              child: {
                allOf: [
                  { '$ref': '#/components/schemas/child' }
                ]
              }
            }
          },
          createCaseCycle: {
            type: :object,
            properties: {
              case_cycle: {
                allOf: [
                  { '$ref': '#/components/schemas/case_cycle' },
                  {
                    type: :object,
                    required: %w[status submitted_on]
                  }
                ]
              }
            }
          },
          updateCaseCycle: {
            type: :object,
            properties: {
              case_cycle: {
                allOf: [
                  { '$ref': '#/components/schemas/case_cycle' }
                ]
              }
            }
          },
          createChildCaseCycle: {
            type: :object,
            properties: {
              child_case_cycle: {
                allOf: [
                  { '$ref': '#/components/schemas/child_case_cycle' },
                  {
                    type: :object,
                    required: %w[case_cycle_id child_id full_days_allowed part_days_allowed subsidy_rule_id user_id]
                  }
                ]
              }
            }
          },
          updateChildCaseCycle: {
            type: :object,
            properties: {
              child_case_cycle: {
                allOf: [
                  { '$ref': '#/components/schemas/child_case_cycle' }
                ]
              }
            }
          },
          createAttendance: {
            type: :object,
            properties: {}
          },
          updateAttendance: {
            type: :object,
            properties: {}
          }
        }
      }
    }
  }

  # Specify the format of the output Swagger file when running 'rswag:specs:swaggerize'.
  # The swagger_docs configuration option has the filename including format in
  # the key, this may want to be changed to avoid putting json in json files.
  # Defaults to json. Accepts ':json' and ':json'.
  config.swagger_format = :json
end
