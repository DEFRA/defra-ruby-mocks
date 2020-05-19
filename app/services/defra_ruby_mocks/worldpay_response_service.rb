# frozen_string_literal: true

module DefraRubyMocks
  class WorldpayResponseService < BaseService

    def run(success_url:, failure_url:)
      parse_reference(success_url)
      locate_resource
      @order = last_order

      response_url(success_url, failure_url)
    end

    private

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

    def locate_resource
      @resource = locate_transient_registration || locate_completed_registration

      raise(MissingRegistrationError, @reference) if @resource.nil?
    end

    def locate_transient_registration
      "WasteCarriersEngine::TransientRegistration"
        .constantize
        .where(token: @reference)
        .first
    end

    def locate_original_registration(reg_identifier)
      "WasteCarriersEngine::Registration"
        .constantize
        .where(reg_identifier: reg_identifier)
        .first
    end

    def locate_completed_registration
      "WasteCarriersEngine::Registration"
        .constantize
        .where(reg_uuid: @reference)
        .first
    end

    def last_order
      @resource.finance_details&.orders&.order_by(dateCreated: :desc)&.first
    end

    def reject_payment?
      company_name = if @resource.class.to_s == "WasteCarriersEngine::OrderCopyCardsRegistration"
                       locate_original_registration(@resource.reg_identifier).company_name
                     else
                       @resource.company_name
                     end

      company_name.downcase.include?("reject")
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

    def query_string(status)
      [
        "orderKey=#{order_key}",
        "paymentStatus=#{status}",
        "paymentAmount=#{order_value}",
        "paymentCurrency=GBP",
        "mac=#{generate_mac(status)}",
        "source=WP"
      ].join("&")
    end

    def response_url(success_url, failure_url)
      separator = @url_format == :new ? "?" : "&"

      if reject_payment?
        url = failure_url
        status = "REFUSED"
      else
        url = success_url
        status = "AUTHORISED"
      end

      [url, separator, query_string(status)].join
    end
  end
end
