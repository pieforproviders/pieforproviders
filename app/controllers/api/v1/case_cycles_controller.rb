# frozen_string_literal: true

# API for user case cycles
class Api::V1::CaseCyclesController < Api::V1::ApiController
  before_action :set_case_cycle, only: %i[show update destroy]
  before_action :authorize_user, only: %i[update destroy]

  # GET /case_cycles
  def index
    @case_cycles = policy_scope(CaseCycle)

    render json: @case_cycles
  end

  # GET /case_cycles/:id
  def show
    render json: @case_cycle
  end

  # POST /case_cycles
  def create
    @case_cycle = if current_user.admin?
                    CaseCycle.new(case_cycle_params)
                  else
                    current_user.case_cycles.new(case_cycle_params)
                  end

    if @case_cycle.save
      render json: @case_cycle, status: :created, location: @case_cycle
    else
      render json: @case_cycle.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /case_cycles/:id
  def update
    if @case_cycle.update(case_cycle_params)
      render json: @case_cycle
    else
      render json: @case_cycle.errors, status: :unprocessable_entity
    end
  end

  # DELETE /case_cycles/:id
  def destroy
    @case_cycle.destroy
  end

  private

  def set_case_cycle
    @case_cycle = policy_scope(CaseCycle).find(params[:id])
  end

  def authorize_user
    authorize @case_cycle
  end

  # rubocop:disable Metrics/MethodLength
  def case_cycle_params
    attributes = %i[case_number
                    copay
                    copay_cents
                    copay_currency
                    copay_frequency
                    effective_on
                    expires_on
                    notified_on
                    status
                    submitted_on]
    attributes << :user_id if current_user.admin?
    params.require(:case_cycle).permit(attributes)
  end
  # rubocop:enable Metrics/MethodLength
end
