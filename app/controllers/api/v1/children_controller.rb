# frozen_string_literal: true

module Api
  module V1
    # API for user children
    class ChildrenController < Api::V1::ApiController
      before_action :set_child, only: %i[show update destroy]
      before_action :set_children, only: %i[index]

      # GET /children
      def index
        render json: ChildBlueprint.render(@children, view: :cases)
      end

      # GET /children/:id
      def show
        render json: @child
      end

      # POST /children
      # rubocop: disable Metrics/AbcSize
      def create
        @child = Child.new(child_params.except(:business_id))
        if @child.approvals.each(&:save) && @child.save && child_params[:business_id].present?
          business = Business.find(child_params[:business_id])
          authorize business, :update? unless current_user.admin?
          @child.child_businesses.create(business:, currently_active: true)
          make_approval_amounts

          render json: @child, status: :created, location: @child
        else
          render json: @child.errors, status: :unprocessable_entity
        end
      end
      # rubocop: enable Metrics/AbcSize

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
        @child.update!(deleted_at: Time.current.to_date)
      end

      # PATCH /children/:id/update_auth
      def update_auth
        child = Child.find(params[:child_id])

        effective_date = params[:current_effective_date]
        expiration_date = params[:current_expiration_date]
        new_effective_date = params[:new_effective_date]
        new_expiration_date = params[:new_expiration_date]

        approval = child.approvals.find_by!(effective_on: effective_date, expires_on: expiration_date)
        approval.update(effective_on: new_effective_date, expires_on: new_expiration_date)
        render json: approval, status: :ok
      end

      private

      def set_child
        @child = policy_scope(Child).find(params[:id])
      end

      def set_children
        @children = if params[:business].present?
                      policy_scope(Child.joins(:child_businesses).where(
                        child_businesses: { business_id: params[:business].split(',') }
                      ).includes(:child_businesses)).order(:last_name)
                    else
                      policy_scope(Child.includes(:child_businesses)).order(:last_name)
                    end
      end

      def child_params
        attributes = []
        attributes += %i[deleted_at] if current_user.admin?
        attributes += %i[
          date_of_birth
          first_name
          last_name
          business_id
          active
          last_active_date
          last_inactive_date
          inactive_reason
        ]
        attributes += [{ approvals_attributes: %i[case_number copay_cents copay_frequency effective_on expires_on] }]
        params.require(:child).permit(attributes, business: [])
      end

      def make_approval_amounts
        case @child.state
        when 'IL'
          IllinoisApprovalAmountGenerator.new(@child, child_params.merge(illinois_approval_amount_params)).call
        end
        # TODO: right now we're doing approval amounts on
        # onboarding CSV processing for NE kids, rather than through the controller
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
