# frozen_string_literal: true

# API for child case cycle billable_occurrences
class Api::V1::BillableOccurrencesController < Api::V1::ApiController
  before_action :set_billable_occurrence, only: %i[show update destroy]
  before_action :authorize_user, only: %i[update destroy]

  # GET /billable_occurrences
  def index
    @billable_occurrences = policy_scope(BillableOccurrence)

    render json: @billable_occurrences, include: ['billable']
  end

  # GET /billable_occurrences/:id
  def show
    render json: @billable_occurrence, include: ['billable']
  end

  # POST /billable_occurrences
  def create
    @billable_occurrence = BillableOccurrence.new(billable_occurrence_params.except(:billable_attributes))
    @billable_occurrence.billable = billable_occurrence_params[:billable_type]&.safe_constantize
                                                                                &.new(billable_occurrence_params[:billable_attributes])

    if @billable_occurrence.save
      render json: @billable_occurrence, include: ['billable'], status: :created, location: @billable_occurrence
    else
      render json: @billable_occurrence.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /billable_occurrences/:id
  def update
    @billable_occurrence.update(child_approval_id: billable_occurrence_params[:child_approval_id])
    @billable_occurrence.billable.update(billable_occurrence_params[:billable_attributes]) if billable_occurrence_params[:billable_attributes].present?

    if @billable_occurrence.save
      render json: @billable_occurrence, include: ['billable']
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
    @billable_occurrence = policy_scope(BillableOccurrence).find(params[:id])
  end

  def authorize_user
    authorize @billable_occurrence
  end

  def billable_occurrence_params
    params.require(:billable_occurrence).permit(:child_approval_id, :billable_type, billable_attributes: %i[check_in check_out])
  end
end
