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
        @errors = Hash.new([])
        @attendance_batch = attendances
        @errors.update(@attendance_batch.map(&:errors).map(&:messages).compact_blank.reduce({}, :merge))

        render json: serialized_response, status: :accepted
      end

      private

      def attendances
        Attendance.create(batch.compact_blank)
      end

      def batch
        attendance_batch_params.to_a.map! do |attendance|
          next Batchable.add_error_and_return_nil(:child_id, @errors) unless attendance[:child_id]

          authorize Child.find(attendance[:child_id]), :update?
          next Batchable.add_error_and_return_nil(:check_in, @errors) unless attendance[:check_in]

          child_approval_id = Batchable.child_approval_id(
            attendance[:child_id],
            attendance[:check_in],
            @errors,
            "child #{attendance[:child_id]} has no active approval for attendance date #{attendance[:check_in]}"
          )
          next unless child_approval_id

          attendance.except(:child_id).merge(child_approval_id: child_approval_id)
        rescue Pundit::NotAuthorizedError
          next Batchable.add_error_and_return_nil(
            :child_id,
            @errors,
            "not allowed to create an attendance for child #{attendance[:child_id]}"
          )
        end
      end

      def attendance_batch_params
        params.permit(attendance_batch: %i[absence check_in check_out child_id]).require(:attendance_batch)
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
