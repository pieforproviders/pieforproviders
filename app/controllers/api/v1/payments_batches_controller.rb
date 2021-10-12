# frozen_string_literal: true

module Api
  module V1
    # API for payment batch entry
    class PaymentsBatchesController < Api::V1::ApiController
      # POST /api/v1/payments_batches
      def create
        @errors = Hash.new([])
        @payments_batch = payments
        @errors.update(@payments_batch.map(&:errors).map(&:messages).compact_blank.reduce({}, :merge))

        render json: serialized_response, status: :accepted
      end

      private

      def payments_batch_params
        params.permit(payments_batch: %i[child_id amount month]).require(:payments_batch)
      end

      def batch
        payments_batch_params.to_a.map! do |payment|
          next if payment_valid?(payment)

          next unless (child_approval_id = get_child_approval_id(payment))

          payment.except(:child_id).merge(child_approval_id: child_approval_id)
        rescue Pundit::NotAuthorizedError
          next add_unauthorized_error(payment)
        end
      end

      def add_unauthorized_error(payment)
        Batchable.add_error_and_return_nil(
          :child_id,
          @errors,
          "not allowed to create a payment for child #{payment[:child_id]}"
        )
      end

      def get_child_approval_id(payment)
        Batchable.child_approval_id(
          payment[:child_id],
          payment[:month],
          @errors,
          "child #{payment[:child_id]} has no active approval for payment date #{payment[:month]}"
        )
      end

      def payment_valid?(payment)
        Batchable.add_error_and_return_nil(:child_id, @errors) unless payment[:child_id]

        authorize Child.find(payment[:child_id]), :update?

        Batchable.add_error_and_return_nil(:month, @errors) unless payment[:month]

        Batchable.add_error_and_return_nil(:amount, @errors) unless payment[:amount]
      end

      def payments
        Payment.create(batch.compact_blank)
      end

      def payment_params
        attributes = []
        attributes += %i[month amount child_approval_id]
        params.require(:payment).permit(attributes)
      end

      def serialized_response
        PaymentBlueprint.render(
          @payments_batch,
          root: :payments,
          meta: { errors: @errors }
        )
      end
    end
  end
end
