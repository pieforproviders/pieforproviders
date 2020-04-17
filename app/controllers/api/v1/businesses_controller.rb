# frozen_string_literal: true

# API for user businesses
class Api::V1::BusinessesController < Api::V1::ApiController
  before_action :set_business, only: %i[show update destroy]

  # GET /businesses
  def index
    @businesses = Business.all

    render json: @businesses
  end

  # GET /businesses/:slug
  def show
    render json: @business
  end

  # POST /businesses
  def create
    @business = Business.new(business_params)

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
    @business = Business.find_by!(slug: params[:slug])
  end

  def business_params
    params.require(:business).permit(
      :active, :category, :id, :name, :slug, :user_id
    )
  end
end
