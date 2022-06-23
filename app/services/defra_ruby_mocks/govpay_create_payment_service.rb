# frozen_string_literal: true

require "securerandom"

module DefraRubyMocks
  class GovpayCreatePaymentService < BaseService

    def run(amount:, description:, return_url:)
      {
        created_date: Time.current,
        state: { status: "created", finished: false },
        _links: {
          self: { href: "#{base_url}/#{payment_id}", method: "GET" },
          next_url: { href: return_url, method: "GET" }
        },
        amount: amount.to_i,
        reference: "12345",
        description: description,
        payment_id: payment_id,
        payment_provider: "sandbox"
      }
    end

    private

    def base_url
      File.join(DefraRubyMocks.configuration.govpay_domain, "/payments")
    end

    def payment_id
      @payment_id ||= SecureRandom.alphanumeric(26)
    end
  end
end
