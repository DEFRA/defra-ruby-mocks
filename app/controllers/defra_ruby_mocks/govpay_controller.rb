# frozen_string_literal: true

module DefraRubyMocks
  class GovpayController < ::DefraRubyMocks::ApplicationController

    skip_before_action :verify_authenticity_token

    def create_payment
      valid_create_params

      store_return_url(params[:return_url])

      render json: GovpayCreatePaymentService.new.run(
        amount: params[:amount], description: params[:description]
      )
    rescue StandardError => e
      Rails.logger.error("MOCKS: Govpay payment creation error: #{e.message}")
      head 500
    end

    # This mocks the Govpay route which presents the payment details page to the user.
    # We don't mock the actual payment details and payment confirmation pages - we go
    # straight to the application callback route.
    def next_url
      response_url = retrieve_return_url
      Rails.logger.warn "Govpay mock calling response URL #{response_url}"
      redirect_to response_url, allow_other_host: true
    rescue RestClient::ExceptionWithResponse => e
      Rails.logger.warn "Govpay mock: RestClient received response: #{e}"
    rescue StandardError => e
      Rails.logger.error("Govpay mock: Error sending request to govpay: #{e}")
      Airbrake.notify(e, message: "Error on govpay request")
    end

    def payment_details
      valid_payment_id
      render json: GovpayGetPaymentService.new.run(payment_id: params[:payment_id])
    rescue StandardError => e
      Rails.logger.error("MOCKS: Govpay payment details error: #{e.message}")
      head 422
    end

    def create_refund
      valid_create_refund_params
      render json: GovpayRequestRefundService.new.run(payment_id: params[:payment_id],
                                                      amount: params[:amount],
                                                      refund_amount_available: params[:refund_amount_available])
    rescue StandardError => e
      Rails.logger.error("MOCKS: Govpay refund error: #{e.message}")
      head 500
    end

    def refund_details
      render json: GovpayRefundDetailsService.new.run(payment_id: params[:payment_id], refund_id: params[:refund_id])
    rescue StandardError => e
      Rails.logger.error("MOCKS: Govpay refund error: #{e.message}")
      head 500
    end

    private

    def s3_bucket_name
      @s3_bucket_name = ENV.fetch("GOVPAY_MOCKS_BUCKET", "defra-ruby-mocks-s3bkt001")
    end

    def return_url_file_name
      @return_url_file_name = "return_url_file"
    end

    # We need to persist the return_url between the initial payment creation request and the execution of next_url.
    # We can't use tmp for multi-server environments so we load the temp file to AWS S3.
    def store_return_url(return_url)
      Rails.logger.warn ":::::: storing return_url #{return_url}"
      AwsBucketService.write(s3_bucket_name, return_url_file_name, return_url)
    end

    def retrieve_return_url
      AwsBucketService.read(s3_bucket_name, return_url_file_name)
    end

    def valid_create_params
      params.require(%i[amount description return_url])
    end

    def valid_payment_id
      return true if params[:payment_id].length > 20 && params[:payment_id].match(/\A[a-zA-Z0-9]*\z/)

      raise ArgumentError, "Invalid Govpay payment ID #{params[:payment_id]}"
    end

    def valid_create_refund_params
      valid_payment_id
      raise ArgumentError, "Invalid refund amount" unless params[:amount].present?
      raise ArgumentError, "Invalid refund amount available" unless params[:refund_amount_available].present?
    end
  end
end
