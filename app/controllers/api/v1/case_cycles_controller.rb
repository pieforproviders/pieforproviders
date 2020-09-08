# frozen_string_literal: true

# API for user case cycles
class Api::V1::CaseCyclesController < Api::V1::ApiController
  before_action :set_case_cycle, only: %i[show update destroy]

  # GET /case_cycles
  def index
    @case_cycles = CaseCycle.all

    render json: @case_cycles
  end

  # GET /case_cycles/:slug
  def show
    render json: @case_cycle
  end

  # POST /case_cycles
  def create
    @case_cycle = CaseCycle.new(case_cycle_params)

    if @case_cycle.save
      render json: @case_cycle, status: :created, location: @case_cycle
    else
      render json: @case_cycle.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /case_cycles/:slug
  def update
    if @case_cycle.update(case_cycle_params)
      render json: @case_cycle
    else
      render json: @case_cycle.errors, status: :unprocessable_entity
    end
  end

  # DELETE /case_cycles/:slug
  def destroy
    @case_cycle.destroy
  end

  private

  def set_case_cycle
    @case_cycle = CaseCycle.find_by!(slug: params[:slug])
  end

  # rubocop:disable Metrics/MethodLength
  def case_cycle_params
    params.require(:case_cycle).permit(
      :case_number,
      :copay,
      :copay_cents,
      :copay_currency,
      :copay_frequency,
      :effective_on,
      :expires_on,
      :id,
      :notified_on,
      :slug,
      :status,
      :submitted_on,
      :user_id
    )
  end
  # rubocop:enable Metrics/MethodLength
end
