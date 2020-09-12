# frozen_string_literal: true

# API for business sites
class Api::V1::SitesController < Api::V1::ApiController
  before_action :set_site, only: %i[show update destroy]

  # GET /sites
  def index
    @sites = Site.all

    render json: @sites
  end

  # GET /sites/:slug
  def show
    render json: @site
  end

  # POST /sites
  def create
    @site = Site.new(site_params)

    if @site.save
      render json: @site, status: :created, location: @site
    else
      render json: @site.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /sites/:slug
  def update
    if @site.update(site_params)
      render json: @site
    else
      render json: @site.errors, status: :unprocessable_entity
    end
  end

  # DELETE /sites/:slug
  def destroy
    # soft delete
    @site.update!(active: false)
  end

  private

  def set_site
    @site = Site.find_by!(slug: params[:slug])
  end

  def site_params
    params.require(:site).permit(
      :active, :id, :name, :slug, :address,
      :city_id, :state_id, :zip_id, :county_id,
      :qris_rating, :business_id
    )
  end
end
