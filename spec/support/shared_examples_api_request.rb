# frozen_string_literal: true

require 'rails_helper'

VALID_API_PATH = '/api/v1'

# These are shared examples for typical API calls for a Rails model.
#
# Some examples expect _item_params_ to be defined (e.g. with a let(:item_params) block)
# to be used as parameters that are sent to the server.
# The examples that expect item_params to be defined end with '... with parameters'.
#
# Ex: Assume you are testing the API calls for creating a Payment. The
#     item_params are the parameters needed to create a Payment.
#
#      it_behaves_like 'it creates an item', Payment, 'payment' do
#        let(:item_params) {
#          {
#            "agency_id": agency_id,
#            "amount_cents": '123400',
#            "care_finished_on": '2020-06-01',
#            "care_started_on": '2020-01-01',
#            "discrepancy_cents": '7890',
#            "paid_on": '2020-07-07'
#          }
#        }
#      end
#
#     You should define 'agency_id' and any other values/variables
#     as needed.
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Examples that test for common error conditions:

# This example expects the following to be defined with a let(:) block:
#  item_params - parameters to be passed to the server
RSpec.shared_examples 'server error responses for wrong api version with parameters' do |item_name|
  context 'on the wrong api version' do
    include_context 'incorrect api version header'
    context 'when authenticated' do
      include_context 'authenticated user'
      response '500', 'internal server error' do
        let(item_name.to_sym) { { item_name => item_params } }
        run_test!
      end
    end

    context 'when not authenticated' do
      response '500', 'internal server error' do
        let(item_name.to_sym) { { item_name => item_params } }
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
#  item_params - parameters to be passed to the server
RSpec.shared_examples '401 error if not authenticated with parameters' do |item_name|
  context 'when not authenticated' do
    response '401', 'not authorized' do
      let(item_name.to_sym) { { item_name => item_params } }
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
#  item_params - parameters to be passed to the server
RSpec.shared_examples '404 not found with parameters' do |item_name|
  response '404', "#{item_name} not found" do
    let(:id) { 'invalid' }
    let(item_name.to_sym) { { item_name => item_params } }
    run_test!
  end
end

RSpec.shared_examples '404 not found' do |item_name|
  response '404', "#{item_name} not found" do
    let(:id) { 'invalid' }
    run_test!
  end
end

# ------------------------------------------------------------------------------

def name_from_class(item_class)
  item_class.name.underscore
end

#  This is the parameter passed to this example:
#    item_class [Class] - the class for the item; is used to create a new item
#      with the item_params
#
RSpec.shared_examples 'it lists all items for a user' do |item_class|
  item_name = name_from_class(item_class)
  item_plural = item_name.pluralize

  path "#{VALID_API_PATH}/#{item_plural}" do
    get "lists all #{item_plural} for a user" do
      tags item_plural

      # rswag requires a call to :produces if you are going to set Accept header info. See Rswag::Specs::RequestFactory#add_headers
      produces 'application/json'

      # parameter name: 'Authorization', in: :header, type: :string, default: 'Bearer <token>'
      # security [{ token: [] }]

      context 'on the right api version' do
        include_context 'correct api version header'
        context 'when authenticated' do
          include_context 'authenticated user'
          response '200', "#{item_plural} found" do
            run_test! do
              expect(response).to match_response_schema(item_plural)
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
#  item_params - parameters to be passed to the server
#
#  These are the parameters passed to this example:
#    item_class [Class] - the class for the item; is used to create a new item
#      with the item_params
#
RSpec.shared_examples 'it retrieves an item for a user' do |item_class|
  item_name = name_from_class(item_class)
  item_plural = item_name.pluralize

  path "#{VALID_API_PATH}/#{item_plural}/{id}" do
    parameter name: :id, in: :path, type: :string
    let(:id) { (item_class.send :create!, item_params).id }

    get "retrieves a #{item_name}" do
      tags item_plural

      # rswag requires a call to :produces if you are going to set Accept header info. See Rswag::Specs::RequestFactory#add_headers
      produces 'application/json'

      # parameter name: 'Authorization', in: :header, type: :string, default: 'Bearer <token>'
      # security [{ token: [] }]

      context 'on the right api version' do
        include_context 'correct api version header'
        context 'when authenticated' do
          include_context 'authenticated user'
          response '200', "#{item_name} found" do
            run_test! do
              expect(response).to match_response_schema(item_name)
            end
          end

          it_behaves_like '404 not found with parameters', item_name
        end

        it_behaves_like '401 error if not authenticated with parameters', item_name
      end

      it_behaves_like 'server error responses for wrong api version with parameters', item_name
    end
  end
end

# This example expects the following to be defined with a let(:) block:
#  item_params - parameters to be passed to the server
#
#  These are the parameters passed to this example:
#    item_class [Class] - the class for the item; is used to create a new item
#      with the item_params
#
RSpec.shared_examples 'it creates an item with the right api version and is authenticated' do |item_class|
  item_name = name_from_class(item_class)
  item_plural = item_name.pluralize
  item_name_symbol = item_name.to_sym

  path "#{VALID_API_PATH}/#{item_plural}" do
    post "creates a #{item_name}" do
      tags item_plural

      # rswag requires a call to :produces if you are going to set Accept header info. See Rswag::Specs::RequestFactory#add_headers
      produces 'application/json'
      consumes 'application/json'

      parameter name: item_name_symbol, in: :body, schema: {
        '$ref' => "#/components/schemas/create#{item_class}"
      }

      context 'on the right api version' do
        include_context 'correct api version header'
        context 'when authenticated' do
          include_context 'authenticated user'

          response '201', "#{item_name} created" do
            let(item_name_symbol) { { item_name => item_params } }
            run_test! do
              expect(response).to match_response_schema(item_name)
            end
          end

          response '422', 'invalid request' do
            let(item_name_symbol) { { item_name => { 'blorf': 'whatever' } } }
            run_test!
          end
        end
      end
    end
  end
end

# This example expects the following to be defined with a let(:) block:
#  item_params - parameters to be passed to the server
#
#  These are the parameters passed to this example:
#    item_class [Class] - the class for the item; is used to create a new item
#      with the item_params.
#
RSpec.shared_examples 'it creates an item' do |item_class|
  item_name = name_from_class(item_class)
  item_plural = item_name.pluralize
  item_name_symbol = item_name.to_sym

  it_behaves_like 'it creates an item with the right api version and is authenticated', item_class

  path "#{VALID_API_PATH}/#{item_plural}" do
    post "creates a #{item_name}" do
      tags item_plural

      # rswag requires a call to :produces if you are going to set Accept header info. See Rswag::Specs::RequestFactory#add_headers
      produces 'application/json'
      consumes 'application/json'

      parameter name: item_name_symbol, in: :body, schema: {
        '$ref' => "#/components/schemas/create#{item_class}"
      }

      context 'on the right api version' do
        include_context 'correct api version header'
        it_behaves_like '401 error if not authenticated with parameters', item_name
      end

      it_behaves_like 'server error responses for wrong api version with parameters', item_name
    end
  end
end

# This example expects the following to be defined with a let(:) block:
#  item_params - parameters to be passed to the server
#  item - the resource
#  owner - the user who owns the resource
#
#  These are the parameters passed to this example:
#    item_class [Class] - the class for the item.
#
RSpec.shared_examples 'admins and resource owners can retrieve an item' do |item_class|
  item_name = name_from_class(item_class)
  item_plural = item_name.pluralize

  path "#{VALID_API_PATH}/#{item_plural}/{id}" do
    parameter name: :id, in: :path, type: :string
    let(:id) do
      item.id
    end

    get "retrieves a #{item_name}" do
      tags item_plural

      produces 'application/json'

      context 'on the right api version' do
        include_context 'correct api version header'
        context 'when authenticated' do
          context 'admin user' do
            include_context 'admin user'
            response '200', "#{item_name} found" do
              run_test! do
                expect(response).to match_response_schema(item_name)
              end
            end
          end

          context 'resource owner' do
            before { sign_in owner }

            response '200', "#{item_name} found" do
              run_test! do
                expect(response).to match_response_schema(item_name)
              end
            end

            it_behaves_like '404 not found with parameters', item_name
          end

          context 'non-owner' do
            include_context 'authenticated user'
            response '404', "#{item_name} not found" do
              run_test!
            end
          end
        end

        it_behaves_like '401 error if not authenticated with parameters', item_name
      end

      it_behaves_like 'server error responses for wrong api version with parameters', item_name
    end
  end
end

# This example expects the following to be defined with a let(:) block:
#  item_params - parameters to be passed to the server
#  item - the resource
#  owner - the user who owns the resource
#
#  These are the parameters passed to this example:
#    item_class [Class] - the class for the item
#    item_name [String] - the name of the item (singular).
#      It is used as a key in the parameters sent to the server
#      and as part of the schema name in the schema definitions.
#      It is pluralized and used for the path and the tags.
#    update_attribute [String] - attribute name to be updated
#    update_valid_value [String | Number | nil] - valid value for the updated value for the attribute
#    update_invalid_value  [String | Number | nil] - invalid value for the attribute so that the server returns a 422 (cannot be updated) error
#
RSpec.shared_examples 'admins and resource owners can update an item' do |item_class, update_attribute, update_valid_value, update_invalid_value|
  item_name = name_from_class(item_class)
  item_plural = item_name.pluralize
  item_name_symbol = item_name.to_sym

  path "#{VALID_API_PATH}/#{item_plural}/{id}" do
    parameter name: :id, in: :path, type: :string
    let(:id) { item.id }

    put "updates a #{item_name}" do
      tags item_plural

      produces 'application/json'
      consumes 'application/json'

      parameter name: item_name_symbol, in: :body, schema: {
        '$ref' => "#/components/schemas/update#{item_class}"
      }
      context 'on the right api version' do
        include_context 'correct api version header'
        context 'when authenticated' do
          let(item_name_symbol) { { item_name => item_params.merge(update_attribute => update_valid_value) } }

          context 'admin user' do
            include_context 'admin user'
            response '200', "#{item_name} updated" do
              run_test! do
                expect(response).to match_response_schema(item_name)
                expect(response.parsed_body[update_attribute]).to eq(update_valid_value)
              end
            end
          end

          context 'resource owner' do
            before { sign_in owner }

            response '200', "#{item_name} updated" do
              run_test! do
                expect(response).to match_response_schema(item_name)
                expect(response.parsed_body[update_attribute]).to eq(update_valid_value)
              end
            end

            response '422', "#{item_name} cannot be updated" do
              let(item_name_symbol) { { item_name => { update_attribute => update_invalid_value } } }
              run_test!
            end

            it_behaves_like '404 not found with parameters', item_name
          end

          context 'non-owner' do
            include_context 'authenticated user'
            response '404', "#{item_name} not found" do
              let(item_name_symbol) { { item_name => item_params.merge(update_attribute => update_valid_value) } }
              run_test!
            end
          end
        end

        it_behaves_like '401 error if not authenticated with parameters', item_name
      end

      it_behaves_like 'server error responses for wrong api version with parameters', item_name
    end
  end
end

# This example expects the following to be defined with a let(:) block:
#  item - the resource
#  owner - the user who owns the resource
#
#  These are the parameters passed to this example:
#    item_class [Class] - the class for the item.
#
RSpec.shared_examples 'admins and resource owners can delete an item' do |item_class|
  item_name = name_from_class(item_class)
  item_plural = item_name.pluralize

  path "#{VALID_API_PATH}/#{item_plural}/{id}" do
    parameter name: :id, in: :path, type: :string
    let(:id) { item.id }

    delete "deletes a #{item_name}" do
      tags item_plural

      produces 'application/json'

      context 'on the right api version' do
        include_context 'correct api version header'
        context 'when authenticated' do
          context 'admin user' do
            include_context 'admin user'
            response '204', "#{item_name} deleted" do
              run_test!
            end
          end

          context 'resource owner' do
            before { sign_in owner }

            response '204', "#{item_name} deleted" do
              run_test!
            end

            it_behaves_like '404 not found', item_name
          end

          context 'non-owner' do
            include_context 'authenticated user'
            response '404', "#{item_name} not found" do
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
#  item_params - parameters to be passed to the server
#
#  These are the parameters passed to this example:
#    item_class [Class] - the class for the item; is used to create a new item
#      with the item_params
#    item_name [String] - the name of the item (singular).
#      It is used as a key in the parameters sent to the server
#      and as part of the schema name in the schema definitions.
#      It is pluralized and used for the path and the tags.
#    update_attribute [String] - attribute name to be updated
#    update_valid_value [String | Number | nil] - valid value for the updated value for the attribute
#    update_invalid_value  [String | Number | nil] - invalid value for the attribute so that the server returns a 422 (cannot be updated) error
#
RSpec.shared_examples 'it updates an item' do |item_class, update_attribute, update_valid_value, update_invalid_value|
  item_name = name_from_class(item_class)
  item_plural = item_name.pluralize
  item_name_symbol = item_name.to_sym

  path "#{VALID_API_PATH}/#{item_plural}/{id}" do
    parameter name: :id, in: :path, type: :string
    let(:id) { (item_class.send :create!, item_params).id }

    put "updates a #{item_name}" do
      tags item_plural

      # rswag requires a call to :produces if you are going to set Accept header info. See Rswag::Specs::RequestFactory#add_headers
      produces 'application/json'
      consumes 'application/json'

      # parameter name: 'Authorization', in: :header, type: :string, default: 'Bearer <token>'

      parameter name: item_name_symbol, in: :body, schema: {
        '$ref' => "#/components/schemas/update#{item_class}"
      }
      # security [{ token: [] }]

      context 'on the right api version' do
        include_context 'correct api version header'
        context 'when authenticated' do
          include_context 'authenticated user'
          response '200', "#{item_name} updated" do
            let(item_name_symbol) { { item_name => item_params.merge(update_attribute => update_valid_value) } }
            run_test! do
              expect(response).to match_response_schema(item_name)
              expect(response.parsed_body[update_attribute]).to eq(update_valid_value)
            end
          end

          response '422', "#{item_name} cannot be updated" do
            let(item_name_symbol) { { item_name => { update_attribute => update_invalid_value } } }
            run_test!
          end

          it_behaves_like '404 not found with parameters', item_name
        end

        it_behaves_like '401 error if not authenticated with parameters', item_name
      end

      it_behaves_like 'server error responses for wrong api version with parameters', item_name
    end
  end
end

# This example expects the following to be defined with a let(:) block:
#  item_params - parameters to be passed to the server
#
#  These are the parameters passed to this example:
#    item_class [Class] - the class for the item; is used to create a new item
#      with the item_params
#
RSpec.shared_examples 'it deletes an item for a user' do |item_class|
  item_name = name_from_class(item_class)
  item_plural = item_name.pluralize

  path "#{VALID_API_PATH}/#{item_plural}/{id}" do
    parameter name: :id, in: :path, type: :string
    let(:id) { (item_class.send :create!, item_params).id }

    delete "deletes a #{item_name}" do
      tags item_plural

      # rswag requires a call to :produces if you are going to set Accept header info. See Rswag::Specs::RequestFactory#add_headers
      produces 'application/json'

      # parameter name: 'Authorization', in: :header, type: :string, default: 'Bearer <token>'
      # security [{ token: [] }]

      context 'on the right api version' do
        include_context 'correct api version header'
        context 'when authenticated' do
          include_context 'authenticated user'
          response '204', "#{item_name} deleted" do
            run_test!
          end

          it_behaves_like '404 not found', item_name
        end

        it_behaves_like '401 error if not authenticated'
      end

      it_behaves_like 'server error responses for wrong api version'
    end
  end
end
