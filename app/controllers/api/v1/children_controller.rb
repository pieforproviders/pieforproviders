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

        if @child.save
          make_illinois_approval_amounts if @child.state == 'IL'
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
          { approvals_attributes: %i[case_number copay copay_frequency effective_on expires_on] }
        ]
        params.require(:child).permit(attributes)
      end

      def make_illinois_approval_amounts
        month_amounts = params.select { |key| key.to_s.start_with?('month') }
        first_month = params['first_month_name']
        year = params['first_month_year']
        return if month_amounts.empty? || [first_month, year].all?(&:nil?)

        ApprovalAmountGenerator.new(@child, month_amounts, first_month, year).call
      end
    end
  end
end
