# frozen_string_literal: true

module DefraRubyMocks
  class GovpayController < ::DefraRubyMocks::ApplicationController

    skip_before_action :verify_authenticity_token

    def create_payment
      valid_create_params

      # Enqueue the payment callback to run after the controller responds
      DefraRubyMocks::GovpayPaymentCallbackJob.perform_later(params[:return_url])

      render json: GovpayCreatePaymentService.new.run(
        amount: params[:amount], description: params[:description], return_url: params[:return_url]
      )
    rescue StandardError => e
      Rails.logger.error("MOCKS: Govpay payment creation error: #{e.message}")
      head 500
    end

    def payment_details
      valid_payment_id
      render json: GovpayGetPaymentService.new.run(payment_id: params[:payment_id])
    rescue StandardError => e
      Rails.logger.error("MOCKS: Govpay payment details error: #{e.message}")
      head 422
    end

    def valid_create_params
      params.require(%i[amount description return_url])
    end

    def valid_payment_id
      return true if params[:payment_id].length > 20 && params[:payment_id].match(/\A[a-zA-Z0-9]*\z/)

      raise ArgumentError, "Invalid Govpay payment ID #{params[:payment_id]}"
    end
  end
end
