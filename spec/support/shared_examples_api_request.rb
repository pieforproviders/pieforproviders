# frozen_string_literal: true

require 'rails_helper'

VALID_API_PATH = '/api/v1'

# These are shared examples for typical API calls for a Rails model.
#
# Some examples expect _record_params_ to be defined (e.g. with a let(:record_params) block)
# to be used as parameters that are sent to the server.
# The examples that expect record_params to be defined end with '... with parameters'.
#
# Ex: Assume you are testing the API calls for creating a Business. The
#     record_params are the parameters needed to create a Business.
#
#     let!(:business_params) do
#       {
#         "name": 'Happy Hearts Child Care',
#         "license_type": 'licensed_center',
#         "user_id": user.id
#       }
#     end
#
#     it_behaves_like 'it creates a record', Business do
#       let(:record_params) { business_params }
#     end
#
#     You should define 'user_id' and any other values/variables
#     as needed.
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Examples that test for common error conditions:

# This example expects the following to be defined with a let(:) block:
#  record_params - parameters to be passed to the server
RSpec.shared_examples 'server error responses for wrong api version with parameters' do |record_name|
  context 'on the wrong api version' do
    include_context 'incorrect api version header'
    context 'when authenticated' do
      include_context 'authenticated user'
      response '500', 'internal server error' do
        let(record_name.to_sym) { { record_name => record_params } }
        run_test!
      end
    end

    context 'when not authenticated' do
      response '500', 'internal server error' do
        let(record_name.to_sym) { { record_name => record_params } }
        run_test!
      end
    end
  end
end

RSpec.shared_examples 'server error responses for wrong api version' do
  context 'on the wrong api version' do
    include_context 'incorrect api version header'
    context 'when authenticated' do
      include_context 'authenticated user'
      response '500', 'internal server error' do
        run_test!
      end
    end

    context 'when not authenticated' do
      response '500', 'internal server error' do
        run_test!
      end
    end
  end
end

# This example expects the following to be defined with a let(:) block:
#  record_params - parameters to be passed to the server
RSpec.shared_examples '401 error if not authenticated with parameters' do |record_name|
  context 'when not authenticated' do
    response '401', 'not authorized' do
      let(record_name.to_sym) { { record_name => record_params } }
      run_test!
    end
  end
end

RSpec.shared_examples '401 error if not authenticated' do
  context 'when not authenticated' do
    response '401', 'not authorized' do
      run_test!
    end
  end
end

# This example expects the following to be defined with a let(:) block:
#  record_params - parameters to be passed to the server
RSpec.shared_examples '404 not found with parameters' do |record_name|
  response '404', "#{record_name} not found" do
    let(:id) { 'invalid' }
    let(record_name.to_sym) { { record_name => record_params } }
    run_test!
  end
end

RSpec.shared_examples '404 not found' do |record_name|
  response '404', "#{record_name} not found" do
    let(:id) { 'invalid' }
    run_test!
  end
end

# ------------------------------------------------------------------------------

def name_from_class(record_class)
  record_class.name.underscore
end

#  This is the parameter passed to this example:
#    record_class [Class] - the class for the record
#
RSpec.shared_examples 'it lists all records for a user' do |record_class|
  record_name = name_from_class(record_class)
  record_plural = record_name.pluralize
  record_name_symbol = record_name.to_sym

  path "#{VALID_API_PATH}/#{record_plural}" do
    get "lists all #{record_plural} for a user" do
      tags record_plural

      # rswag requires a call to :produces if you are going to set Accept header info. See Rswag::Specs::RequestFactory#add_headers
      produces 'application/json'

      # parameter name: 'Authorization', in: :header, type: :string, default: 'Bearer <token>'
      # security [{ token: [] }]

      context 'on the right api version' do
        include_context 'correct api version header'
        context 'when authenticated' do
          let!(:owner_records) { create_list(record_name_symbol, count, owner_attributes) }
          let!(:non_owner_records) { create_list(record_name_symbol, count, non_owner_attributes) }

          context 'admin user' do
            include_context 'admin user'
            response '200', "#{record_plural} found" do
              run_test! do
                expect(JSON.parse(response.body).size).to eq(count * 2)
                expect(response).to match_response_schema(record_plural)
              end
            end
          end

          context 'resource owner' do
            before { sign_in owner }

            response '200', "#{record_plural} found" do
              run_test! do
                expect(JSON.parse(response.body).size).to eq(count)
                expect(response).to match_response_schema(record_plural)
              end
            end
          end

          context 'non-owner' do
            include_context 'authenticated user'
            response '200', "#{record_plural} found" do
              run_test! do
                expect(JSON.parse(response.body).size).to eq(0)
              end
            end
          end
        end

        it_behaves_like '401 error if not authenticated'
      end

      it_behaves_like 'server error responses for wrong api version'
    end
  end
end

# This example expects the following to be defined with a let(:) block:
#  record_params - parameters to be passed to the server
#
#  These are the parameters passed to this example:
#    record_class [Class] - the class for the record; is used to create a new record
#      with the record_params
#
RSpec.shared_examples 'it retrieves a record for a user' do |record_class|
  record_name = name_from_class(record_class)
  record_plural = record_name.pluralize

  path "#{VALID_API_PATH}/#{record_plural}/{id}" do
    parameter name: :id, in: :path, type: :string
    let(:id) { (record_class.send :create!, record_params).id }

    get "retrieves a #{record_name}" do
      tags record_plural

      # rswag requires a call to :produces if you are going to set Accept header info. See Rswag::Specs::RequestFactory#add_headers
      produces 'application/json'

      # parameter name: 'Authorization', in: :header, type: :string, default: 'Bearer <token>'
      # security [{ token: [] }]

      context 'on the right api version' do
        include_context 'correct api version header'
        context 'when authenticated' do
          include_context 'authenticated user'
          response '200', "#{record_name} found" do
            run_test! do
              expect(response).to match_response_schema(record_name)
            end
          end

          it_behaves_like '404 not found with parameters', record_name
        end

        it_behaves_like '401 error if not authenticated with parameters', record_name
      end

      it_behaves_like 'server error responses for wrong api version with parameters', record_name
    end
  end
end

# This example expects the following to be defined with a let(:) block:
#  record_params - parameters to be passed to the server
#
#  These are the parameters passed to this example:
#    record_class [Class] - the class for the record; is used to create a new record
#      with the record_params
#
RSpec.shared_examples 'it creates a record with the right api version and is authenticated' do |record_class|
  record_name = name_from_class(record_class)
  record_plural = record_name.pluralize
  record_name_symbol = record_name.to_sym

  path "#{VALID_API_PATH}/#{record_plural}" do
    post "creates a #{record_name}" do
      tags record_plural

      # rswag requires a call to :produces if you are going to set Accept header info. See Rswag::Specs::RequestFactory#add_headers
      produces 'application/json'
      consumes 'application/json'

      parameter name: record_name_symbol, in: :body, schema: {
        '$ref' => "#/components/schemas/create#{record_class}"
      }

      context 'on the right api version' do
        include_context 'correct api version header'
        context 'when authenticated' do
          include_context 'authenticated user'

          response '201', "#{record_name} created" do
            let(record_name_symbol) { { record_name => record_params } }
            run_test! do
              expect(response).to match_response_schema(record_name)
            end
          end

          response '422', 'invalid request' do
            let(record_name_symbol) { { record_name => { blorf: 'whatever' } } }
            run_test!
          end
        end
      end
    end
  end
end

# This example expects the following to be defined with a let(:) block:
#  record_params - parameters to be passed to the server
#
#  These are the parameters passed to this example:
#    record_class [Class] - the class for the record; is used to create a new record
#      with the record_params.
#
RSpec.shared_examples 'it creates a record' do |record_class|
  record_name = name_from_class(record_class)
  record_plural = record_name.pluralize
  record_name_symbol = record_name.to_sym

  it_behaves_like 'it creates a record with the right api version and is authenticated', record_class

  path "#{VALID_API_PATH}/#{record_plural}" do
    post "creates a #{record_name}" do
      tags record_plural

      # rswag requires a call to :produces if you are going to set Accept header info. See Rswag::Specs::RequestFactory#add_headers
      produces 'application/json'
      consumes 'application/json'

      parameter name: record_name_symbol, in: :body, schema: {
        '$ref' => "#/components/schemas/create#{record_class}"
      }

      context 'on the right api version' do
        include_context 'correct api version header'
        it_behaves_like '401 error if not authenticated with parameters', record_name
      end

      it_behaves_like 'server error responses for wrong api version with parameters', record_name
    end
  end
end

# This example expects the following to be defined with a let(:) block:
#  record_params - parameters to be passed to the server
#  record - the resource
#  owner - the user who owns the resource
#
#  These are the parameters passed to this example:
#    record_class [Class] - the class for the record.
#
RSpec.shared_examples 'admins and resource owners can retrieve a record' do |record_class|
  record_name = name_from_class(record_class)
  record_plural = record_name.pluralize

  path "#{VALID_API_PATH}/#{record_plural}/{id}" do
    parameter name: :id, in: :path, type: :string
    let(:id) do
      record.id
    end

    get "retrieves a #{record_name}" do
      tags record_plural

      produces 'application/json'

      context 'on the right api version' do
        include_context 'correct api version header'
        context 'when authenticated' do
          context 'admin user' do
            include_context 'admin user'
            response '200', "#{record_name} found" do
              run_test! do
                expect(response).to match_response_schema(record_name)
              end
            end
          end

          context 'resource owner' do
            before { sign_in owner }

            response '200', "#{record_name} found" do
              run_test! do
                expect(response).to match_response_schema(record_name)
              end
            end

            it_behaves_like '404 not found with parameters', record_name
          end

          context 'non-owner' do
            include_context 'authenticated user'
            response '404', "#{record_name} not found" do
              run_test!
            end
          end
        end

        it_behaves_like '401 error if not authenticated with parameters', record_name
      end

      it_behaves_like 'server error responses for wrong api version with parameters', record_name
    end
  end
end

# This example expects the following to be defined with a let(:) block:
#  record_params - parameters to be passed to the server
#  record - the resource
#  owner - the user who owns the resource
#
#  These are the parameters passed to this example:
#    record_class [Class] - the class for the record
#    record_name [String] - the name of the record (singular).
#      It is used as a key in the parameters sent to the server
#      and as part of the schema name in the schema definitions.
#      It is pluralized and used for the path and the tags.
#    update_attribute [String] - attribute name to be updated
#    update_valid_value [String | Number | nil] - valid value for the updated value for the attribute
#    update_invalid_value  [String | Number | nil] - invalid value for the attribute so that the server returns a 422 (cannot be updated) error
#
RSpec.shared_examples 'admins and resource owners can update a record' do |record_class, update_attribute, update_valid_value, update_invalid_value|
  record_name = name_from_class(record_class)
  record_plural = record_name.pluralize
  record_name_symbol = record_name.to_sym

  path "#{VALID_API_PATH}/#{record_plural}/{id}" do
    parameter name: :id, in: :path, type: :string
    let(:id) { record.id }

    put "updates a #{record_name}" do
      tags record_plural

      produces 'application/json'
      consumes 'application/json'

      parameter name: record_name_symbol, in: :body, schema: {
        '$ref' => "#/components/schemas/update#{record_class}"
      }
      context 'on the right api version' do
        include_context 'correct api version header'
        context 'when authenticated' do
          let(record_name_symbol) { { record_name => record_params.merge(update_attribute => update_valid_value) } }

          context 'admin user' do
            include_context 'admin user'
            response '200', "#{record_name} updated" do
              run_test! do
                expect(response).to match_response_schema(record_name)
                expect(response.parsed_body[update_attribute]).to eq(update_valid_value)
              end
            end
          end

          context 'resource owner' do
            before { sign_in owner }

            response '200', "#{record_name} updated" do
              run_test! do
                expect(response).to match_response_schema(record_name)
                expect(response.parsed_body[update_attribute]).to eq(update_valid_value)
              end
            end

            response '422', "#{record_name} cannot be updated" do
              let(record_name_symbol) { { record_name => { update_attribute => update_invalid_value } } }
              run_test!
            end

            it_behaves_like '404 not found with parameters', record_name
          end

          context 'non-owner' do
            include_context 'authenticated user'
            response '404', "#{record_name} not found" do
              let(record_name_symbol) { { record_name => record_params.merge(update_attribute => update_valid_value) } }
              run_test!
            end
          end
        end

        it_behaves_like '401 error if not authenticated with parameters', record_name
      end

      it_behaves_like 'server error responses for wrong api version with parameters', record_name
    end
  end
end

# This example expects the following to be defined with a let(:) block:
#  record_params - parameters to be passed to the server
#  record - the resource
#  owner - the user who owns the resource
#  association - the name of the associated object in the response
#
#  These are the parameters passed to this example:
#    record_class [Class] - the class for the record
#    record_name [String] - the name of the record (singular).
#      It is used as a key in the parameters sent to the server
#      and as part of the schema name in the schema definitions.
#      It is pluralized and used for the path and the tags.
#    update_attribute [String] - attribute name to be updated
#    update_valid_value [String | Number | nil] - valid value for the updated value for the attribute
#    update_invalid_value  [String | Number | nil] - invalid value for the attribute so that the server returns a 422 (cannot be updated) error
#
RSpec.shared_examples 'admins and resource owners can update a nested record' do |record_class, update_attribute, update_valid_value, update_invalid_value|
  record_name = name_from_class(record_class)
  record_plural = record_name.pluralize
  record_name_symbol = record_name.to_sym

  path "#{VALID_API_PATH}/#{record_plural}/{id}" do
    parameter name: :id, in: :path, type: :string
    let(:id) { record.id }

    put "updates a #{record_name}" do
      tags record_plural

      produces 'application/json'
      consumes 'application/json'

      parameter name: record_name_symbol, in: :body, schema: {
        '$ref' => "#/components/schemas/update#{record_class}"
      }
      context 'on the right api version' do
        include_context 'correct api version header'
        context 'when authenticated' do
          let(record_name_symbol) { { record_name => record_params.merge(update_attribute => update_valid_value) } }

          context 'admin user' do
            include_context 'admin user'
            response '200', "#{record_name} updated" do
              run_test! do
                expect(response).to match_response_schema(record_name)
                expect(response.parsed_body[association]).to include(JSON.parse(update_valid_value.to_json))
              end
            end
          end

          context 'resource owner' do
            before { sign_in owner }

            response '200', "#{record_name} updated" do
              run_test! do
                expect(response).to match_response_schema(record_name)
                expect(response.parsed_body[association]).to include(JSON.parse(update_valid_value.to_json))
              end
            end

            response '422', "#{record_name} cannot be updated" do
              let(record_name_symbol) { { record_name => { update_attribute => update_invalid_value } } }
              run_test!
            end

            it_behaves_like '404 not found with parameters', record_name
          end

          context 'non-owner' do
            include_context 'authenticated user'
            response '404', "#{record_name} not found" do
              let(record_name_symbol) { { record_name => record_params.merge(update_attribute => update_valid_value) } }
              run_test!
            end
          end
        end

        it_behaves_like '401 error if not authenticated with parameters', record_name
      end

      it_behaves_like 'server error responses for wrong api version with parameters', record_name
    end
  end
end

# This example expects the following to be defined with a let(:) block:
#  record - the resource
#  owner - the user who owns the resource
#
#  These are the parameters passed to this example:
#    record_class [Class] - the class for the record.
#
RSpec.shared_examples 'admins and resource owners can delete a record' do |record_class|
  record_name = name_from_class(record_class)
  record_plural = record_name.pluralize

  path "#{VALID_API_PATH}/#{record_plural}/{id}" do
    parameter name: :id, in: :path, type: :string
    let(:id) { record.id }

    delete "deletes a #{record_name}" do
      tags record_plural

      produces 'application/json'

      context 'on the right api version' do
        include_context 'correct api version header'
        context 'when authenticated' do
          context 'admin user' do
            include_context 'admin user'
            response '204', "#{record_name} deleted" do
              run_test!
            end
          end

          context 'resource owner' do
            before { sign_in owner }

            response '204', "#{record_name} deleted" do
              run_test!
            end

            it_behaves_like '404 not found', record_name
          end

          context 'non-owner' do
            include_context 'authenticated user'
            response '404', "#{record_name} not found" do
              run_test!
            end
          end
        end

        it_behaves_like '401 error if not authenticated'
      end

      it_behaves_like 'server error responses for wrong api version'
    end
  end
end

# This example expects the following to be defined with a let(:) block:
#  record_params - parameters to be passed to the server
#
#  These are the parameters passed to this example:
#    record_class [Class] - the class for the record; is used to create a new record
#      with the record_params
#    record_name [String] - the name of the record (singular).
#      It is used as a key in the parameters sent to the server
#      and as part of the schema name in the schema definitions.
#      It is pluralized and used for the path and the tags.
#    update_attribute [String] - attribute name to be updated
#    update_valid_value [String | Number | nil] - valid value for the updated value for the attribute
#    update_invalid_value  [String | Number | nil] - invalid value for the attribute so that the server returns a 422 (cannot be updated) error
#
RSpec.shared_examples 'it updates a record' do |record_class, update_attribute, update_valid_value, update_invalid_value, is_time_param = false|
  record_name = name_from_class(record_class)
  record_plural = record_name.pluralize
  record_name_symbol = record_name.to_sym

  path "#{VALID_API_PATH}/#{record_plural}/{id}" do
    parameter name: :id, in: :path, type: :string
    let(:id) { (record_class.send :create!, record_params).id }

    put "updates a #{record_name}" do
      tags record_plural

      # rswag requires a call to :produces if you are going to set Accept header info. See Rswag::Specs::RequestFactory#add_headers
      produces 'application/json'
      consumes 'application/json'

      # parameter name: 'Authorization', in: :header, type: :string, default: 'Bearer <token>'

      parameter name: record_name_symbol, in: :body, schema: {
        '$ref' => "#/components/schemas/update#{record_class}"
      }
      # security [{ token: [] }]

      context 'on the right api version' do
        include_context 'correct api version header'
        context 'when authenticated' do
          include_context 'authenticated user'
          response '200', "#{record_name} updated" do
            let(record_name_symbol) { { record_name => record_params.merge(update_attribute => update_valid_value) } }
            run_test! do
              expect(response).to match_response_schema(record_name)
              if is_time_param
                expect(DateTime.parse(update_valid_value)).to eq(DateTime.parse(response.parsed_body[update_attribute]))
              else
                expect(response.parsed_body[update_attribute]).to eq(update_valid_value)
              end
            end
          end

          response '422', "#{record_name} cannot be updated" do
            let(record_name_symbol) { { record_name => { update_attribute => update_invalid_value } } }
            run_test!
          end

          it_behaves_like '404 not found with parameters', record_name
        end

        it_behaves_like '401 error if not authenticated with parameters', record_name
      end

      it_behaves_like 'server error responses for wrong api version with parameters', record_name
    end
  end
end

# This example expects the following to be defined with a let(:) block:
#  record_params - parameters to be passed to the server
#
#  These are the parameters passed to this example:
#    record_class [Class] - the class for the record; is used to create a new record
#      with the record_params
#
RSpec.shared_examples 'it deletes a record for a user' do |record_class|
  record_name = name_from_class(record_class)
  record_plural = record_name.pluralize

  path "#{VALID_API_PATH}/#{record_plural}/{id}" do
    parameter name: :id, in: :path, type: :string
    let(:id) { (record_class.send :create!, record_params).id }

    delete "deletes a #{record_name}" do
      tags record_plural

      # rswag requires a call to :produces if you are going to set Accept header info. See Rswag::Specs::RequestFactory#add_headers
      produces 'application/json'

      # parameter name: 'Authorization', in: :header, type: :string, default: 'Bearer <token>'
      # security [{ token: [] }]

      context 'on the right api version' do
        include_context 'correct api version header'
        context 'when authenticated' do
          include_context 'authenticated user'
          response '204', "#{record_name} deleted" do
            run_test!
          end

          it_behaves_like '404 not found', record_name
        end

        it_behaves_like '401 error if not authenticated'
      end

      it_behaves_like 'server error responses for wrong api version'
    end
  end
end
