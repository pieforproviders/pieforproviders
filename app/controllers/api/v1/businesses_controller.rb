# frozen_string_literal: true

# API for user businesses
class Api::V1::BusinessesController < Api::V1::ApiController
  before_action :set_business, only: %i[show update destroy]
  before_action :authorize_user, only: %i[update destroy]

  # GET /businesses
  def index
    @businesses = policy_scope(Business)

    render json: @businesses
  end

  # GET /businesses/:slug
  def show
    render json: @business
  end

  # POST /businesses
  def create
    @business = if current_user.admin?
                  Business.new(business_params)
                else
                  current_user.businesses.new(business_params)
                end

    if @business.save
      render json: @business, status: :created, location: @business
    else
      render json: @business.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /businesses/:slug
  def update
    if @business.update(business_params)
      render json: @business
    else
      render json: @business.errors, status: :unprocessable_entity
    end
  end

  # DELETE /businesses/:slug
  def destroy
    # soft delete
    @business.update!(active: false)
  end

  private

  def set_business
    @business = policy_scope(Business).find_by!(slug: params[:slug])
  end

  def authorize_user
    authorize @business
  end

  def business_params
    attributes = %i[name category]
    attributes += %i[user_id active] if current_user.admin?
    params.require(:business).permit(attributes)
  end
end
