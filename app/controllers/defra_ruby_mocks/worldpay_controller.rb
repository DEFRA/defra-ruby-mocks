# frozen_string_literal: true

module DefraRubyMocks
  class WorldpayController < ApplicationController

    before_action :set_default_response_format

    def payments_service
      @merchant_code = "merchant100"
      @order_code = "order200"
      @worldpay_id = generate_world_pay_id
      @worldpay_url = "#{base_url}?OrderKey=#{@merchant_code}%5E#{@order_code}"

      respond_to :xml
    end

    private

    def set_default_response_format
      request.format = :xml
    end

    def generate_world_pay_id
      # Worldpay seems to generate 10 digit numbers for all its ID's. So we
      # replicate that here with this.
      # https://stackoverflow.com/a/31043825
      rand(1e9...1e10).to_i
    end

    def base_url
      File.join(DefraRubyMocks.configuration.worldpay_domain, "/worldpay/dispatcher")
    end

  end
end
