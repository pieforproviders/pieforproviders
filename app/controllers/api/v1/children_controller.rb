# frozen_string_literal: true

module Api
  module V1
    # API for user children
    class ChildrenController < Api::V1::ApiController
      before_action :set_child, only: %i[show update destroy]
      before_action :authorize_user, only: %i[update destroy]

      # GET /children
      def index
        @children = policy_scope(Child)

        render json: @children
      end

      # GET /children/:id
      def show
        render json: @child
      end

      # POST /children
      def create
        @child = Child.new(child_params)
        if @child.approvals.each(&:save) && @child.save
          make_approval_amounts
          render json: @child, status: :created, location: @child
        else
          render json: @child.errors, status: :unprocessable_entity
        end
      end

      # PATCH/PUT /children/:id
      def update
        if @child.update(child_params)
          render json: @child
        else
          render json: @child.errors, status: :unprocessable_entity
        end
      end

      # DELETE /children/:id
      def destroy
        # soft delete
        @child.update!(active: false)
      end

      private

      def set_child
        @child = policy_scope(Child).find(params[:id])
      end

      def authorize_user
        authorize @child
      end

      def child_params
        attributes = []
        attributes += %i[active] if current_user.admin?
        attributes += [
          :date_of_birth,
          :full_name,
          :business_id,
          { approvals_attributes: %i[case_number copay_cents copay_frequency effective_on expires_on] }
        ]
        params.require(:child).permit(attributes)
      end

      def make_approval_amounts
        case @child.state
        when 'NE'
          NebraskaApprovalAmountGenerator.new(@child, child_params.merge(nebraska_approval_amount_params)).call
        when 'IL'
          IllinoisApprovalAmountGenerator.new(@child, child_params.merge(illinois_approval_amount_params)).call
        end
      end

      def nebraska_approval_amount_params
        {
          approval_periods: params[:approval_periods]
        }
      end

      def illinois_approval_amount_params
        {
          first_month_name: params[:first_month_name],
          first_month_year: params[:first_month_year],
          month_amounts: params.select { |key| key.to_s.start_with?('month') }
        }
      end
    end
  end
end
