# frozen_string_literal: true

# API for agencies.  Note that this class is 'read only' for client apps.
#   Data required for Agencies will be added to the db via rake tasks or other external means.
class Api::V1::AgenciesController < Api::V1::ApiController
  before_action :set_agency, only: %i[show update destroy]

  # GET /agencies
  def index
    @agencies = Agency.all

    render json: @agencies
  end

  # GET /agencies/1
  def show
    render json: @agency
  end

  # POST /agencies
  def create
    @agency = Agency.new(agency_params)

    if @agency.save
      render json: @agency, status: :created, location: @agency
    else
      render json: @agency.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /agencies/1
  def update
    if @agency.update(agency_params)
      render json: @agency
    else
      render json: @agency.errors, status: :unprocessable_entity
    end
  end

  # DELETE /agencies/1
  def destroy
    @agency.destroy
  end

  private

  def set_agency
    @agency = Agency.find(params[:id])
  end

  def agency_params
    params.require(:agency).permit(:active, :name, :state_id)
  end
end
