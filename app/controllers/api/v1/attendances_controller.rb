# frozen_string_literal: true

# API for child case cycle attendances
class Api::V1::AttendancesController < Api::V1::ApiController
  before_action :set_attendance, only: %i[show update destroy]

  # GET /attendances
  def index
    @attendances = Attendance.all

    render json: @attendances
  end

  # GET /attendances/:id
  def show
    render json: @attendance
  end

  # POST /attendances
  # TODO: need to calculate the attendance_duration based on the subsidy_rule
  # for the child_case_cycle
  def create
    @attendance = Attendance.new(attendance_params)

    if @attendance.save
      render json: @attendance, status: :created, location: @attendance
    else
      render json: @attendance.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /attendances/:id
  def update
    if @attendance.update(attendance_params)
      render json: @attendance
    else
      render json: @attendance.errors, status: :unprocessable_entity
    end
  end

  # DELETE /attendances/:id
  def destroy
    @attendance.destroy
  end

  private

  def set_attendance
    @attendance = Attendance.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def attendance_params
    params.require(:attendance).permit(:check_in,
                                       :check_out,
                                       :child_case_cycle_id,
                                       :starts_on,
                                       :total_time_in_care)
  end
end
