# frozen_string_literal: true

# API for user children
class Api::V1::ChildCaseCyclesController < Api::V1::ApiController
  before_action :set_child_case_cycle, only: %i[show update destroy]
  before_action :authorize_user, only: %i[update destroy]

  # GET /child_case_cycles
  def index
    @child_case_cycles = policy_scope(ChildCaseCycle)

    render json: @child_case_cycles
  end

  # GET /child_case_cycles/:id
  def show
    render json: @child_case_cycle
  end

  # POST /child_case_cycles
  def create
    @child_case_cycle = ChildCaseCycle.new(child_case_cycle_params)

    authorize @child_case_cycle
    if @child_case_cycle.save
      render json: @child_case_cycle, status: :created, location: @child_case_cycle
    else
      render json: @child_case_cycle.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /child_case_cycles/:id
  def update
    if @child_case_cycle.update(child_case_cycle_params)
      render json: @child_case_cycle
    else
      render json: @child_case_cycle.errors, status: :unprocessable_entity
    end
  end

  # DELETE /child_case_cycles/:id
  def destroy
    @child_case_cycle.destroy
  end

  private

  def set_child_case_cycle
    @child_case_cycle = policy_scope(ChildCaseCycle).find(params[:id])
  end

  def authorize_user
    authorize @child_case_cycle
  end

  def child_case_cycle_params
    params.require(:child_case_cycle).permit(:case_cycle_id,
                                             :child_id,
                                             :full_days_allowed,
                                             :part_days_allowed,
                                             :subsidy_rule_id)
  end
end
