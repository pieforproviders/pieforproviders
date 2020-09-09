# frozen_string_literal: true

# API for user children
class Api::V1::ChildCaseCyclesController < Api::V1::ApiController
  before_action :set_child_case_cycle, only: %i[show update destroy]

  # GET /child_case_cycles
  def index
    @child_case_cycles = ChildCaseCycle.all

    render json: @child_case_cycles
  end

  # GET /child_case_cycles/:slug
  def show
    render json: @child_case_cycle
  end

  # POST /child_case_cycles
  def create
    @child_case_cycle = ChildCaseCycle.new(child_case_cycle_params)

    if @child_case_cycle.save
      render json: @child_case_cycle, status: :created, location: @child_case_cycle
    else
      render json: @child_case_cycle.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /child_case_cycles/:slug
  def update
    if @child_case_cycle.update(child_case_cycle_params)
      render json: @child_case_cycle
    else
      render json: @child_case_cycle.errors, status: :unprocessable_entity
    end
  end

  # DELETE /child_case_cycles/:slug
  def destroy
    @child_case_cycle.destroy
  end

  private

  def set_child_case_cycle
    @child_case_cycle = ChildCaseCycle.find_by!(slug: params[:slug])
  end

  def child_case_cycle_params
    params.require(:child_case_cycle).permit(:id,
                                             :slug,
                                             :user_id,
                                             :child_id,
                                             :subsidy_rule_id,
                                             :case_cycle_id,
                                             :part_days_allowed,
                                             :full_days_allowed)
  end
end
