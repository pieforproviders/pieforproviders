# frozen_string_literal: true

# API for payments
class Api::V1::PaymentsController < Api::V1::ApiController
  before_action :set_payment, only: %i[show update destroy]

  # GET /payments
  def index
    @payments = Payment.all

    render json: @payments
  end

  # GET /payments/:id
  def show
    render json: @payment
  end

  # POST /payments
  def create
    @payment = Payment.new(payment_params)

    if @payment.save
      render json: @payment, status: :created, location: @payment
    else
      render json: @payment.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /payments/:id
  def update
    if @payment.update(payment_params)
      render json: @payment
    else
      render json: @payment.errors, status: :unprocessable_entity
    end
  end

  # DELETE /payments/:id
  def destroy
    @payment.destroy
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_payment
    @payment = Payment.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def payment_params
    params.require(:payment).permit(:agency_id,
                                    :amount,
                                    :amount_cents,
                                    :amount_currency,
                                    :care_started_on,
                                    :care_finished_on,
                                    :discrepancy,
                                    :discrepancy_cents,
                                    :discrepancy_currency,
                                    :paid_on)
  end
end
