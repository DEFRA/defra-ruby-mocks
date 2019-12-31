# frozen_string_literal: true

module DefraRubyMocks
  class WorldpayRequestService < BaseService
    def run(data)
      check_config

      xml = Nokogiri::XML(data)
      @merchant_code = extract_merchant_code(xml)
      @order_code = extract_order_code(xml)

      {
        merchant_code: @merchant_code,
        order_code: @order_code,
        id: generate_id,
        url: generate_url
      }
    end

    private

    def check_config
      domain = DefraRubyMocks.configuration.worldpay_domain

      raise InvalidConfigError.new(:worldpay_domain) if domain.blank?
    end

    def extract_merchant_code(xml)
      payment_service = xml.at_xpath("//paymentService")
      payment_service.attribute("merchantCode").text
    end

    def extract_order_code(xml)
      order = xml.at_xpath("//order")
      order.attribute("orderCode").text
    end

    def generate_id
      # Worldpay seems to generate 10 digit numbers for all its ID's. So we
      # replicate that here with this.
      # https://stackoverflow.com/a/31043825
      rand(1e9...1e10).to_i.to_s
    end

    def generate_url
      "#{base_url}?OrderKey=#{@merchant_code}%5E#{@order_code}"
    end

    def base_url
      File.join(DefraRubyMocks.configuration.worldpay_domain, "/worldpay/dispatcher")
    end
  end
end
