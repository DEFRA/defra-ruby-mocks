# frozen_string_literal: true

module DefraRubyMocks
  class WorldpayController < ApplicationController

    before_action :set_default_response_format

    def payments_service
      response_values = WorldpayRequestService.run(request.body.read)

      @merchant_code = response_values[:merchant_code]
      @order_code = response_values[:order_code]
      @worldpay_id = response_values[:id]
      @worldpay_url = response_values[:url]

      respond_to :xml
    rescue StandardError
      head 500
    end

    def dispatcher
      success_url = params[:successURL]
      redirect_to WorldpayResponseService.run(success_url)
    rescue StandardError
      head 500
    end

    private

    def set_default_response_format
      request.format = :xml
    end

  end
end
