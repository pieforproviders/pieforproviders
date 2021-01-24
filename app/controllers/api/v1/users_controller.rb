# frozen_string_literal: true

# API for application users
class Api::V1::UsersController < Api::V1::ApiController
  # GET /users
  def index
    authorize User
    @users = User.all

    render json: UserBlueprint.render(@users)
  end

  # GET /profile
  def show
    render json: UserBlueprint.render(current_user)
  end

  # GET /case_list_for_dashboard
  def case_list_for_dashboard
    date_now = DateTime.now.in_time_zone(current_user.timezone)
    if current_user.state == 'NE'
      render json: UserBlueprint
        .render(
          policy_scope(User),
          view: :nebraska_dashboard,
          from_date: date_now,
          timezone: current_user.timezone
        )
    else
      render json: UserBlueprint
        .render(
          policy_scope(User),
          view: :illinois_dashboard,
          from_date: date_now,
          timezone: current_user.timezone
        )
    end
  end
end
