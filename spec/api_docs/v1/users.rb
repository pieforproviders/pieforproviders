# frozen_string_literal: true

module ApiDocs
  module V1
    module Users
      extend Dox::DSL::Syntax

      document :api do
        resource 'Users' do
          group 'Users'
          desc 'Resource definition for operations on the users endpoint'
        end
      end

      document :index do
        action 'Get Users' do
          verb 'GET'
          path '/api/v1/users'
          desc 'Fetch users as a non-admin user and as an administrator'
        end
      end
    end
  end
end
