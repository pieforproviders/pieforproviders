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

  # GET /sites/:slug
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
    @site = policy_scope(Site).find_by!(slug: params[:slug])
  end

  def authorize_user
    authorize @site
  end

  def site_params
    attribues = %i[name address city_id state_id zip_id county_id qris_rating business_id]
    attribues << :active if current_user&.admin?
    params.require(:site).permit(attribues)
  end
end
