# frozen_string_literal: true

module Docs
  module V1
    module Users
      extend Dox::DSL::Syntax

      document :api do
        group 'Users' do
          desc 'Group for all resources related to users'
        end

        resource 'Users' do
          group 'Users'
          desc 'Resource definition for user actions'
        end
      end

      document :index do
        action 'Get Users' do
          desc 'Fetch all users from the database'
          path '/api/v1/users'
          verb 'GET'
        end
      end
    end
  end
end
