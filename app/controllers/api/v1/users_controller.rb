# frozen_string_literal: true

module Api
  module V1
    # API for application users
    class UsersController < Api::V1::ApiController
      before_action :set_user, only: %i[show]
      before_action :authorize_user, only: %i[show]

      # GET /users
      def index
        @users = policy_scope(User.includes(:businesses))
        authorize User

        render json: UserBlueprint.render(@users)
      end

      # GET /profile or GET /users/:id
      def show
        render json: UserBlueprint.render(@user)
      end

      # GET /case_list_for_dashboard
      def case_list_for_dashboard
        if current_user.state == 'NE' || current_user.admin?
          render json: nebraska_dashboard
        else
          render json: illinois_dashboard
        end
      end

      private

      def set_user
        @user = params[:id] ? policy_scope(User.includes(:businesses, :children)).find(params[:id]) : current_user
      end

      def authorize_user
        authorize @user
      end

      def filter_date
        if params[:filter_date]
          Time.zone.parse(params[:filter_date])&.at_end_of_day
        else
          Time.current.at_end_of_day
        end
      end

      def nebraska_dashboard
        UserBlueprint.render(
          policy_scope(
            User
              .joins(:businesses)
              .where(businesses: { children: Child.approved_for_date(filter_date).not_deleted })
              .includes(:businesses, :children, :child_approvals, :approvals, :service_days, :schedules)
          ),
          view: :nebraska_dashboard,
          filter_date: filter_date
        )
      end

      def illinois_dashboard
        UserBlueprint.render(
          policy_scope(User.includes(:businesses)),
          view: :illinois_dashboard,
          filter_date: filter_date
        )
      end
    end
  end
end
