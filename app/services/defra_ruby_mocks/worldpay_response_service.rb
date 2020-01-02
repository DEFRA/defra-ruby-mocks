# frozen_string_literal: true

module DefraRubyMocks
  class WorldpayResponseService < BaseService

    def run(success_url)
      parse_reference(success_url)
      @registration = locate_record
      @order = last_order

      Rails.logger.debug "Reference #{@reference}"
      Rails.logger.debug "Registration #{@registration}"
      Rails.logger.debug "Order #{@order}"
      Rails.logger.debug "Url format #{@url_format}"
      Rails.logger.debug "Query string #{query_string}"
      Rails.logger.debug response_url(success_url)

      response_url(success_url)
    end

    private

    def parse_reference(url)
      path = URI.parse(url).path
      parts = path.split("/")
      Rails.logger.debug parts

      if parts[1].downcase == "your-registration"
        # ["", "your-registration", "xP2zj9nqWYI0SAsMtGZn6w", "worldpay", "success", "1577812071", "NEWREG"]
        @reference = parts[-5]
        @url_format = :old
      else
        # ["", "fo", "jq6sTt2RQguAu4ZyKFfRg9zm", "worldpay", "success"]
        @reference = parts[-3]
        @url_format = :new
      end
    end

    def locate_record
      locate_transient_registration || locate_registration
    end

    def locate_transient_registration
      "WasteCarriersEngine::TransientRegistration"
        .constantize
        .where(token: @reference)
        .first
    end

    def locate_registration
      "WasteCarriersEngine::Registration"
        .constantize
        .where(reg_uuid: @reference)
        .first
    end

    def last_order
      @registration.finance_details&.orders&.order_by(dateCreated: :desc)&.first
    end

    def order_key
      [
        DefraRubyMocks.configuration.worldpay_admin_code,
        DefraRubyMocks.configuration.worldpay_merchant_code,
        @order.order_code
      ].join("^")
    end

    def order_value
      @order.total_amount.to_s
    end

    def generate_mac
      data = [
        order_key,
        order_value,
        "GBP",
        "AUTHORISED",
        DefraRubyMocks.configuration.worldpay_mac_secret
      ]

      Digest::MD5.hexdigest(data.join).to_s
    end

    def query_string
      [
        "orderKey=#{order_key}",
        "paymentStatus=AUTHORISED",
        "paymentAmount=#{order_value}",
        "paymentCurrency=GBP",
        "mac=#{generate_mac}",
        "source=WP"
      ].join("&")
    end

    def response_url(success_url)
      if @url_format == :new
        "#{success_url}?#{query_string}"
      else
        "#{success_url}&#{query_string}"
      end
    end
  end
end
