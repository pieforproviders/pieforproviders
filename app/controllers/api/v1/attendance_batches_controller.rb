# frozen_string_literal: true

module Api
  module V1
    # API for attendance batch entry
    class AttendanceBatchesController < Api::V1::ApiController
      # POST /api/v1/attendance_batches

      # custom error handling here tacks on the child_id can't be blank error, to mimic
      # model validations even though attendances don't need it, and throw out child_approval_id errors
      # because API integrations currently won't have that information, it's all internal only
      # API users should not have to know which approval is active in order to submit an attendance

      def create
        @child_errors = []

        @attendance_batch = Attendance.create(attendances)
        @errors = @attendance_batch.map(&:errors).map(&:messages).map { |msg| msg.except(:child_approval) }.compact_blank + @child_errors

        render json: serialized_response, status: :accepted
      end

      private

      def attendances
        attendance_batch_params.map do |attendance|
          next attendance.except(:child_id).merge(child_approval_id: child_approval_id(attendance)) if attendance[:child_id]

          @child_errors << { child_id: ["can't be blank"] }
          attendance
        end
      end

      def child_approval_id(attendance)
        Child.find(attendance[:child_id]).active_child_approval(Date.parse(attendance[:check_in])).id
      end

      def attendance_batch_params
        params.permit(attendance_batch: %i[check_in check_out child_id]).require(:attendance_batch)
      end

      def serialized_response
        AttendanceBlueprint.render(
          @attendance_batch,
          root: :attendances,
          meta: { errors: @errors }
        )
      end
    end
  end
end
