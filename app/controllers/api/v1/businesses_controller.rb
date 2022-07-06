# frozen_string_literal: true

module Api
  module V1
    # API for user businesses
    class BusinessesController < Api::V1::ApiController
      before_action :set_business, only: %i[show update destroy]
      before_action :set_businesses, only: %i[index]

      # GET /businesses
      def index
        render json: @businesses
      end

      # GET /businesses/:id
      def show
        render json: @business
      end

      # POST /businesses
      def create
        @business = if current_user.admin?
                      Business.new(business_params)
                    else
                      current_user.businesses.new(business_params)
                    end

        if @business.save
          render json: @business, status: :created, location: @business
        else
          render json: @business.errors, status: :unprocessable_entity
        end
      end

      # PATCH/PUT /businesses/:id
      def update
        if @business.update(business_params)
          render json: @business
        else
          render json: @business.errors, status: :unprocessable_entity
        end
      end

      # DELETE /businesses/:id
      def destroy
        # soft delete
        if @business.children.any?(&:active?)
          @business.errors.add(:children, :not_permitted, message: 'cannot delete a business with active children')
          render json: @business.errors, status: :unprocessable_entity
        else
          @business.update!(deleted_at: Time.current.to_date)
        end
      end

      private

      def set_business
        @business = policy_scope(Business).find(params[:id])
      end

      def set_businesses
        @businesses = policy_scope(Business)
      end

      def business_params
        attributes = %i[county license_type name zipcode]
        attributes += %i[user_id active] if current_user.admin?
        params.require(:business).permit(attributes)
      end
    end
  end
end
