# frozen_string_literal: true

module Api
  module V1
    # API for application users
    class UsersController < Api::V1::ApiController
      before_action :set_user, only: %i[show update destroy]
      before_action :set_users, only: %i[index]

      # GET /users
      def index
        authorize User

        render json: UserBlueprint.render(@users)
      end

      # GET /profile or GET /users/:id
      def show
        render json: UserBlueprint.render(@user)
      end

      def create
        authorize User

        @user = User.new(user_params)
        if @user.save
          render json: UserBlueprint.render(@user)
        else
          render json: @user.errors, status: :unprocessable_entity
        end
      end

      # PUT /users
      def update
        if @user
          if @user.update(user_params)
            render json: UserBlueprint.render(@user)
          else
            render json: @user.errors, status: :unprocessable_entity
          end
        else
          render status: :not_found
        end
      end

      def destroy
        if @user
          if @user.destroy
            render status: :no_content
          else
            render json: @user.errors, status: :unprocessable_entity
          end
        else
          render status: :not_found
        end
      end

      # GET /case_list_for_dashboard
      def case_list_for_dashboard
        if current_user.state == 'NE'
          render json: nebraska_dashboard
        else
          render json: illinois_dashboard
        end
      end

      private

      def set_user
        @user = params[:id] ? policy_scope(User).find(params[:id]) : current_user
      end

      def set_users
        @users = policy_scope(User)
      end

      def filter_date
        params[:filter_date] ? Time.zone.parse(params[:filter_date])&.at_end_of_day : Time.current.at_end_of_day
      end

      def dashboard_query(state)
        if params[:business].present?
          state.with_dashboard_case.selected_business(params[:business])
        else
          state.with_dashboard_case
        end
      end

      def nebraska_dashboard
        UserBlueprint.render(
          policy_scope(dashboard_query(User.nebraska)),
          view: :nebraska_dashboard,
          filter_date:
        )
      end

      def illinois_dashboard
        UserBlueprint.render(
          policy_scope(dashboard_query(User.illinois)),
          view: :illinois_dashboard,
          filter_date:
        )
      end

      def user_params
        params.require(:user).permit(:email,
                                     :active,
                                     :full_name,
                                     :first_name,
                                     :last_name,
                                     :greeting_name,
                                     :language,
                                     :opt_in_email,
                                     :opt_in_text,
                                     :phone_number,
                                     :state,
                                     :get_from_pie,
                                     :organization,
                                     :password,
                                     :password_confirmation,
                                     :service_agreement_accepted,
                                     :timezone,
                                     :stressed_about_billing,
                                     :accept_more_subsidy_families,
                                     :not_as_much_money,
                                     :too_much_time)
      end
    end
  end
end
