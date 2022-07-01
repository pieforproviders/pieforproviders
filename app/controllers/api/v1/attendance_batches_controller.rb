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

      # TODO: this will get moved into the command pattern soon

      def create
        @errors = Hash.new([])
        @attendance_batch = attendances
        render json: serialized_response, status: :accepted
      end

      private

      attr_reader :attendance_batch,
                  :attendance_params,
                  :initial_attendance_params,
                  :errors

      def attendances
        batch.compact_blank.map do |attendance_params|
          @attendance_params = attendance_params
          ActiveRecord::Base.transaction do
            if absence_type
              service_day
            else
              Commands::Attendance::Create.new(
                check_in: check_in,
                child_id: child.id,
                check_out: check_out
              ).create.service_day
            end
          end
        end
      end

      def batch
        attendance_batch_params.to_a.map! do |initial_attendance_params|
          @initial_attendance_params = initial_attendance_params
          next unless check_params

          authorize Child.find(initial_attendance_params[:child_id]), :update?

          next unless child_approval_id

          initial_attendance_params.except(:child_id).merge(child_approval_id: child_approval_id)
        rescue Pundit::NotAuthorizedError
          next add_error_and_return_nil(
            :child_id,
            "not allowed to create an attendance for child #{initial_attendance_params[:child_id]}"
          )
        end
      end

      def check_params
        case initial_attendance_params
        when ->(params) { !params.key?(:check_in) }
          add_error_and_return_nil(:check_in)
        when ->(params) { !params.key?(:child_id) }
          add_error_and_return_nil(:child_id)
        else
          true
        end
      end

      def child_approval_error_message
        "child #{initial_attendance_params[:child_id]} has no active approval " \
          "for attendance date #{initial_attendance_params[:check_in]}"
      end

      def check_in
        @check_in = attendance_params[:check_in]
      end

      def check_out
        @check_out = attendance_params[:check_out]
      end

      def absence_type
        @absence_type = attendance_params.dig(:service_day_attributes, :absence_type) || attendance_params[:absence]
      end

      def child_approval_id
        id = Child
             .find(initial_attendance_params[:child_id])
             &.active_child_approval(Date.parse(initial_attendance_params[:check_in]))&.id
        @child_approval_id = id || add_error_and_return_nil(:child_approval_id, child_approval_error_message)
      end

      def child
        @child = ChildApproval.find(attendance_params[:child_approval_id]).child
      end

      def service_day
        @service_day = ServiceDay.find_by(child: child, date: date)&.update!(absence_type: absence_type) ||
                       ServiceDay.create!(child: child, date: date, absence_type: absence_type)
      rescue StandardError => e
        add_error_and_return_nil(:service_day, e.message)
      end

      def date
        @date = attendance_params.dig(:service_day_attributes, :date) ||
                attendance_params[:check_in]&.in_time_zone(child&.timezone)&.at_beginning_of_day
      end

      def add_error_and_return_nil(key, message = "can't be blank")
        errors[key] += [message]
        nil
      end

      def attendance_batch_params
        params.permit(
          attendance_batch: [
            :absence,
            :check_in,
            :check_out,
            :child_id,
            {
              service_day_attributes: [:absence_type]
            }
          ]
        ).require(:attendance_batch)
      end

      def serialized_response
        ServiceDayBlueprint.render(
          attendance_batch.compact_blank,
          root: :service_days,
          meta: { errors: errors }
        )
      end
    end
  end
end
