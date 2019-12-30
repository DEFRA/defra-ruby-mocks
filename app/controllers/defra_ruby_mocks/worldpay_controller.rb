# frozen_string_literal: true

module DefraRubyMocks
  class WorldpayController < ApplicationController

    before_action :set_default_response_format

    def payments_service
      @merchant_code = "merchant100"
      @order_code = "order200"
      @worldpay_id = "worldpayid200"
      url = "localhost:3002/fo/mocks/worldpay/dispatcher"
      @worldpay_url = "#{url}?OrderKey=#{@merchant_code}%5E#{@order_code}"

      respond_to :xml
    end

    private

    def set_default_response_format
      request.format = :xml
    end

  end
end
