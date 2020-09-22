# frozen_string_literal: true

# API for business sites
class Api::V1::SitesController < Api::V1::ApiController
  before_action :set_site, only: %i[show update destroy]
  before_action :authorize_user, only: %i[update destroy]

  # GET /sites
  def index
    @sites = policy_scope(Site)

    render json: @sites
  end

  # GET /sites/:id
  def show
    render json: @site
  end

  # POST /sites
  def create
    @site = Site.new(site_params)

    authorize @site
    if @site.save
      render json: @site, status: :created, location: @site
    else
      render json: @site.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /sites/:id
  def update
    if @site.update(site_params)
      render json: @site
    else
      render json: @site.errors, status: :unprocessable_entity
    end
  end

  # DELETE /sites/:id
  def destroy
    # soft delete
    @site.update!(active: false)
  end

  private

  def set_site
    @site = policy_scope(Site).find(params[:id])
  end

  def authorize_user
    authorize @site
  end

  def site_params
    attributes = %i[address
                    business_id
                    city_id
                    county_id
                    name
                    qris_rating
                    state_id
                    zip_id]
    attributes << :active if current_user&.admin?
    params.require(:site).permit(attributes)
  end
end
