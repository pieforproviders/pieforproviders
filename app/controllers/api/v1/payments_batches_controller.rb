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

      def child_approval_id(child_id, date)
        Child.find(child_id)
          &.active_child_approval(Date.parse(date))
          &.id || add_error_and_return_nil(
          :child_approval_id,
          "child #{child_id} has no active approval for payment date #{date}"
        )
      end

      def batch
        payments_batch_params.to_a.map! do |payment|
          next add_error_and_return_nil(:child_id) unless payment[:child_id]

          authorize Child.find(payment[:child_id]), :update?
          next add_error_and_return_nil(:month) unless payment[:month]

          next add_error_and_return_nil(:amount) unless payment[:amount]

          child_approval_id = child_approval_id(payment[:child_id], payment[:month])
          next unless child_approval_id

          payment.except(:child_id).merge(child_approval_id: child_approval_id)
        rescue Pundit::NotAuthorizedError
          next add_error_and_return_nil(
            :child_id,
            "not allowed to create a payment for child #{payment[:child_id]}"
          )
        end
      end

      def payments
        Payment.create(batch.compact_blank)
      end

      def payment_params
        attributes = []
        attributes += %i[month amount child_approval_id]
        params.require(:payment).permit(attributes)
      end

      def set_payment
        @payment = policy_scope(Payment).find(params[:id])
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
