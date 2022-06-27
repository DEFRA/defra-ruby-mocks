# frozen_string_literal: true

require "securerandom"

module DefraRubyMocks
  class GovpayCreatePaymentService < BaseService

    def run(amount:, description:, return_url:)
      JSON.parse(File.read("spec/fixtures/files/govpay/create_payment_created_response.json")).merge(
        {
          _links: {
            self: { href: "#{base_url}/#{payment_id}", method: "GET" },
            next_url: { href: return_url, method: "GET" }
          },
          amount: amount.to_i,
          description: description,
          payment_id: payment_id
        }
      )
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
