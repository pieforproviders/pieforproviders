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
      swagger: '2.0',
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
      definitions: {
        createUser: {
          type: :object,
          properties: {
            user: {
              type: :object,
              properties: {
                email: { type: :string, example: 'user@user.com' },
                full_name: { type: :string, example: 'Marlee Matlin' },
                greeting_name: { type: :string, example: 'Marlee' },
                language: { type: :string, example: 'Farsi' },
                organization: { type: :string, example: 'Society for the Promotion of Elfish Welfare' },
                password: { type: :string, example: 'password1234!' },
                password_confirmation: { type: :string, example: 'password1234!' },
                phone_number: { type: :string, example: '888-888-8888' },
                service_agreement_accepted: { type: :boolean, example: 'true' },
                timezone: { type: :string, example: 'Central Time (US & Canada)' }
              },
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
          }
        },
        updateUser: {
          type: :object,
          properties: {
            user: {
              type: :object,
              properties: {
                email: { type: :string, example: 'user@user.com' },
                full_name: { type: :string, example: 'Marlee Matlin' },
                greeting_name: { type: :string, example: 'Marlee' },
                language: { type: :string, example: 'Farsi' },
                organization: { type: :string, example: 'Society for the Promotion of Elfish Welfare' },
                phone_number: { type: :string, example: '888-888-8888' },
                service_agreement_accepted: { type: :boolean, example: 'true' },
                timezone: { type: :string, example: 'Eastern Time (US & Canada)' }
              }
            }
          }
        },
        createBusiness: {
          type: :object,
          properties: {
            business: {
              type: :object,
              properties: {
                name: { type: :string, example: 'Harlequin Child Care' },
                category: { type: :string, example: 'license_exempt_home' },
                user_id: { type: :uuid, example: '3fa57706-f5bb-4d40-9350-85871f698d55' }
              },
              required: %w[
                name
                category
                user_id
              ]
            }
          }
        },
        updateBusiness: {
          type: :object,
          properties: {
            business: {
              type: :object,
              properties: {
                name: { type: :string, example: 'Harlequin Child Care' },
                category: { type: :string, example: 'license_exempt_home' },
                active: { type: :boolean, example: 'true' }
              }
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
                user_id: { type: :uuid, example: '3fa57706-f5bb-4d40-9350-85871f698d55' },
                child_sites_attributes: {
                  type: :array,
                  items: {
                    type: :object,
                    required: %w[site_id],
                    properties: {
                      site_id: { type: :uuid, example: 'a42270e4-e4d4-485c-a57d-ccbad5729030' },
                      started_care: { type: :string, example: '2018-12-13' },
                      ended_care: { type: :string, example: '2019-08-04' }
                    }
                  }
                }
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
              type: :object,
              properties: {
                ccms_id: { type: :string, example: '987654321' },
                date_of_birth: { type: :string, example: '1992-11-01' },
                full_name: { type: :string, example: 'Sean Flannery' }
              }
            }
          }
        },
        createSite: {
          type: :object,
          properties: {
            site: {
              type: :object,
              properties: {
                name: { type: :string, example: 'Marberry Educational Center' },
                address: { type: :string, example: '1100 Marks Ave' },
                city: { type: :string, example: 'Galesburg' },
                state: { type: :string, example: 'TX' },
                zip: { type: :string, example: '54321' },
                county: { type: :string, example: 'Tigh' },
                qris_rating: { type: :string, example: '2' },
                business_id: { type: :uuid, example: '3fa57706-f5bb-4d40-9350-85871f698d55' }
              },
              required: %w[
                name
                address
                city
                state
                zip
                county
                business_id
              ]
            }
          }
        },
        updateSite: {
          type: :object,
          properties: {
            site: {
              type: :object,
              properties: {
                name: { type: :string, example: 'Marberry Educational Center' },
                address: { type: :string, example: '1100 Marks Ave' },
                city: { type: :string, example: 'Galesburg' },
                state: { type: :string, example: 'TX' },
                zip: { type: :string, example: '54321' },
                county: { type: :string, example: 'Tigh' },
                qris_rating: { type: :string, example: '2' },
                business_id: { type: :uuid, example: '3fa57706-f5bb-4d40-9350-85871f698d55' }
              }
            }
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
