# frozen_string_literal: true

# API for child case cycle billable_occurrences
class Api::V1::BillableOccurrencesController < Api::V1::ApiController
  before_action :set_billable_occurrence, only: %i[show update destroy]

  # GET /billable_occurrences
  def index
    @billable_occurrences = BillableOccurrence.all

    render json: @billable_occurrences.include(:billable)
  end

  # GET /billable_occurrences/:id
  def show
    render json: @billable_occurrence.include(:billable)
  end

  # POST /billable_occurrences
  # TODO: need to calculate the billable_occurrence_duration based on the subsidy_rule
  def create
    @billable_occurrence = BillableOccurrence.new(billable_occurrence_params)

    if @billable_occurrence.save
      render json: @billable_occurrence.include(:billable), status: :created, location: @billable_occurrence
    else
      render json: @billable_occurrence.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /billable_occurrences/:id
  def update
    if @billable_occurrence.update(billable_occurrence_params)
      render json: @billable_occurrence.include(:billable)
    else
      render json: @billable_occurrence.errors, status: :unprocessable_entity
    end
  end

  # DELETE /billable_occurrences/:id
  def destroy
    @billable_occurrence.destroy
  end

  private

  def set_billable_occurrence
    @billable_occurrence = BillableOccurrence.find(params[:id])
  end

  def billable_occurrence_params
    params.require(:billable_occurrence).permit(:child_approval_id,
                                                { attendance_params: %i[check_in check_out total_time_in_care] })
  end
end
