# frozen_string_literal: true

module DefraRubyMocks
  class WorldpayResponseService < BaseService

    def run(success_url:, failure_url:, pending_url:, cancel_url:)
      urls = {
        success: success_url,
        failure: failure_url,
        pending: pending_url,
        cancel: cancel_url
      }

      parse_reference(urls[:success])
      @resource = WorldpayResourceService.run(reference: @reference)

      generate_response(urls)
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
      return :SENT_FOR_AUTHORISATION if @resource.company_name.include?("pending")
      return :CANCELLED if @resource.company_name.include?("cancel")

      :AUTHORISED
    end

    def url(payment_status, urls)
      return urls[:failure] if %i[REFUSED STUCK].include?(payment_status)
      return urls[:pending] if payment_status == :SENT_FOR_AUTHORISATION
      return urls[:cancel] if payment_status == :CANCELLED

      urls[:success]
    end

    # Generate a mac that matches what Worldpay would generate
    #
    # For whatever reason, if the payment is cancelled by the user Worldpay does
    # not include the payment status in the mac it generates. Plus the order of
    # things in the array is important.
    def generate_mac(status)
      data = [
        order_key,
        order_value,
        "GBP"
      ]
      data << status unless status == :CANCELLED
      data << DefraRubyMocks.configuration.worldpay_mac_secret

      Digest::MD5.hexdigest(data.join).to_s
    end

    def generate_response(urls)
      status = payment_status

      WorldpayResponse.new(
        url(status, urls),
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
