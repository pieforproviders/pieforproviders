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
        title: 'API V1',
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
                phone: { type: :string, example: '888-888-8888' },
                service_agreement_accepted: { type: :boolean, example: 'true' },
                timezone: { type: :string, example: 'Eastern Time (US & Canada)' }
              },
              required: %w[
                email
                full_name
                language
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
                phone: { type: :string, example: '888-888-8888' },
                service_agreement_accepted: { type: :boolean, example: 'true' },
                timezone: { type: :string, example: 'Eastern Time (US & Canada)' }
              }
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
              name: { type: :string, example: 'Harlequin Childcare' },
              category: { type: :string, example: 'license_exempt_home' }
            },
            required: %w[
              name
              category
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
              name: { type: :string, example: 'Harlequin Childcare' },
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
              first_name: { type: :string, example: 'Seamus' },
              full_name: { type: :string, example: 'Seamus Finnigan' },
              last_name: { type: :string, example: 'Finnigan' }
            },
            required: %w[
              first_name
              last_name
              date_of_birth
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
              first_name: { type: :string, example: 'Sean' },
              full_name: { type: :string, example: 'Sean Flannery' },
              last_name: { type: :string, example: 'Flannery' }
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
