# frozen_string_literal: true

# API for application users
class Api::V1::UsersController < Api::V1::ApiController
  before_action :set_user, only: %i[show update destroy]

  # GET /users
  def index
    @users = User.all

    render json: @users
  end

  # GET /users/:user_id
  def show
    render json: @user
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

  # PATCH/PUT /users/:user_id
  def update
    if @user.update(user_params)
      render json: @user
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  # DELETE /users/:user_id
  def destroy
    # soft delete
    @user.update!(active: false)
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(
      :active, :email, :full_name, :greeting_name,
      :id, :language, :mobile, :opt_in_email,
      :opt_in_phone, :opt_in_text, :phone,
      :service_agreement_accepted, :timezone
    )
  end
end
