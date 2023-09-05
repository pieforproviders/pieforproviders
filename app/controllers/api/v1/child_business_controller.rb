# frozen_string_literal: true

module Api
  module V1
    # API for child businesses
    class ChildBusinessController < Api::V1::ApiController
      before_action :set_child_business, only: %i[show update destroy]

      # GET /child_businesses/:id
      def show
        render json: @child_business
      end

      # POST /child_businesses
      def create
        @child_business = ChildBusiness.new(child_business_params)
        if @child_business.save
          render json: @child_business, status: :created, location: @child_business
        else
          render json: @child_business.errors, status: :unprocessable_entity
        end
      end

      # PATCH/PUT /child_businesses/:id
      def update
        if @child_business.update(child_business_params)
          render json: @child_business
        else
          render json: @child_business.errors, status: :unprocessable_entity
        end
      end

      # DELETE /child_businesses/:id
      def destroy
        if @child_business.destroy
          render json: { message: 'Relationship deleted successfully' }, status: :ok
        else
          render json: @child_business.errors, status: :unprocessable_entity
        end
      end

      private

      def set_child_business
        @child_business = ChildBusiness.find(params[:id])
      end

      def child_business_params
        params.require(:child_business).permit(:child_id, :business_id, :active)
      end
    end
  end
end
