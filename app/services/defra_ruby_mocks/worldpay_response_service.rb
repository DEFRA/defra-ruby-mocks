# frozen_string_literal: true

module DefraRubyMocks
  class WorldpayResponseService < BaseService

    def run(success_url:, failure_url:)
      parse_reference(success_url)
      @resource = WorldpayResourceService.run(reference: @reference)

      generate_response(success_url, failure_url)
    end

    private

    WorldpayResponse = Struct.new(:supplied_url, :separator, :order_key, :mac, :value, :status, :reference) do
      def url
        [supplied_url, separator, params].join
      end

      def params
        [
          "orderKey=#{order_key}",
          "paymentStatus=#{status}",
          "paymentAmount=#{value}",
          "paymentCurrency=GBP",
          "mac=#{mac}",
          "source=WP"
        ].join("&")
      end
    end

    def parse_reference(url)
      path = URI.parse(url).path
      parts = path.split("/")

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

    def order_key
      [
        DefraRubyMocks.configuration.worldpay_admin_code,
        DefraRubyMocks.configuration.worldpay_merchant_code,
        @resource.order.order_code
      ].join("^")
    end

    def order_value
      @resource.order.total_amount.to_s
    end

    def payment_status
      return :REFUSED if @resource.company_name.include?("reject")
      return :STUCK if @resource.company_name.include?("stuck")

      :AUTHORISED
    end

    def generate_mac(status)
      data = [
        order_key,
        order_value,
        "GBP",
        status,
        DefraRubyMocks.configuration.worldpay_mac_secret
      ]

      Digest::MD5.hexdigest(data.join).to_s
    end

    def generate_response(success_url, failure_url)
      status = payment_status

      WorldpayResponse.new(
        status == :AUTHORISED ? success_url : failure_url,
        @url_format == :new ? "?" : "&",
        order_key,
        generate_mac(status),
        order_value,
        status,
        @reference
      )
    end
  end
end
