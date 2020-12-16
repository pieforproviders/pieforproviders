# frozen_string_literal: true

# API for application users
class Api::V1::UsersController < Api::V1::ApiController
  before_action :set_user, only: %i[update destroy]
  before_action :authorize_user, only: %i[update destroy]
  skip_before_action :authenticate_user!, only: %i[create]

  # GET /users
  def index
    authorize User
    @users = User.all

    render json: @users
  end

  # GET /profile
  def show
    render json: current_user
  end

  # POST /users
  def create
    @user = User.new(user_params)

    if @user.save
      render json: @user, status: :created, location: @user
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /users/:slug
  def update
    if @user.update(user_params)
      render json: @user
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  # DELETE /users/:slug
  def destroy
    # soft delete
    @user.update!(active: false)
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_user
    @user = policy_scope(User).find_by!(slug: params[:slug])
  end

  def authorize_user
    authorize @user
  end

  def user_params
    attributes = %i[
      email full_name greeting_name language
      opt_in_email opt_in_text organization password
      password_confirmation phone_number phone_type
      service_agreement_accepted timezone
    ]
    attributes << :active if current_user&.admin?
    params.require(:user).permit(attributes)
  end
end
