# frozen_string_literal: true

# API Controller for ChildCaseCyclePayments
class Api::V1::ChildCaseCyclePaymentsController < Api::V1::ApiController
  before_action :set_child_case_cycle_payment, only: %i[show update destroy]

  # GET /child_case_cycle_payments
  def index
    @child_case_cycle_payments = ChildCaseCyclePayment.all

    render json: @child_case_cycle_payments
  end

  # GET /child_case_cycle_payments/:id
  def show
    render json: @child_case_cycle_payment
  end

  # POST /child_case_cycle_payments
  def create
    @child_case_cycle_payment = ChildCaseCyclePayment.new(child_case_cycle_payment_params)

    if @child_case_cycle_payment.save
      render json: @child_case_cycle_payment, status: :created, location: @child_case_cycle_payment
    else
      render json: @child_case_cycle_payment.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /child_case_cycle_payments/:id
  def update
    if @child_case_cycle_payment.update(child_case_cycle_payment_params)
      render json: @child_case_cycle_payment
    else
      render json: @child_case_cycle_payment.errors, status: :unprocessable_entity
    end
  end

  # DELETE /child_case_cycle_payments/:id
  def destroy
    @child_case_cycle_payment.destroy
  end

  private

  def set_child_case_cycle_payment
    @child_case_cycle_payment = ChildCaseCyclePayment.find(params[:id])
  end

  def child_case_cycle_payment_params
    params.require(:child_case_cycle_payment).permit(:amount,
                                                     :amount_cents,
                                                     :amount_currency,
                                                     :child_case_cycle_id,
                                                     :discrepancy,
                                                     :discrepancy_cents,
                                                     :discrepancy_currency,
                                                     :payment_id)
  end
end
