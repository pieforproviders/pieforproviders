# frozen_string_literal: true

# API for user businesses
class Api::V1::BusinessesController < Api::V1::ApiController
  before_action :set_user
  before_action :set_user_business, only: %i[show update destroy]

  # GET /users/:user_id/businesses
  def index
    render json: @user.businesses
  end

  # GET /users/:user_id/businesses/:business_id
  def show
    render json: @business
  end

  # POST /users/:user_id/businesses
  def create
    business = @user.businesses.create!(business_params)

    if business.save
      render json: @user, include: :businesses, status: :created, location: @user
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /users/:user_id/businesses/:business_id
  def update
    if @business.update(business_params)
      render json: @user, include: :businesses
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  # DELETE /users/:user_id/businesses/:business_id
  def destroy
    # soft delete
    @business.update!(active: false)
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_user
    @user = User.includes(:businesses).find(params[:user_id])
  end

  def set_user_business
    @business = @user.businesses.find_by!(id: params[:id]) if @user
  end

  def business_params
    params.require(:business).permit(
      :category, :id, :name, :user_id
    )
  end
end
