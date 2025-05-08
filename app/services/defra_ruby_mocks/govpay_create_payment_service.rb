# frozen_string_literal: true

require "securerandom"

module DefraRubyMocks
  class GovpayCreatePaymentService < BaseService

    include CanUseAwsS3

    def run(amount:, description:)
      success_response.merge(
        {
          _links: {
            self: { href: "#{base_url}/#{payment_id}", method: "GET" },
            next_url: { href: "#{base_url}/secure/next-url-uuid-abc123", method: "GET" }
          },
          amount: amount.to_i,
          description: description,
          payment_id: payment_id
        }
      )
    end

    private

    def test_payment_response_status
      response_status(response_status_filename: "test_payment_response_status", default_status: "created")
    end

    def base_url
      File.join(DefraRubyMocks.configuration.govpay_domain, "/payments")
    end

    def payment_id
      @payment_id ||= SecureRandom.alphanumeric(26)
    end

    # rubocop:disable Metrics/MethodLength
    def success_response
      {
        created_date: "2020-03-03T16:17:19.554Z",
        state: {
          status: test_payment_response_status,
          finished: false
        },
        _links: {
          self: {
            href: "https://publicapi.payments.service.gov.uk/v1/payments/hu20sqlact5260q2nanm0q8u93",
            method: "GET"
          },
          next_url: {
            href: "https://www.payments.service.gov.uk/secure/bb0a272c-8eaf-468d-b3xf-ae5e000d2231",
            method: "GET"
          }
        },
        amount: 14_500,
        reference: "12345",
        description: "Pay your council tax",
        return_url: "https://your.service.gov.uk/completed",
        payment_id: "hu20sqlact5260q2nanm0q8u93",
        payment_provider: "worldpay",
        provider_id: "10987654321"
      }
    end
    # rubocop:enable Metrics/MethodLength

  end
end
