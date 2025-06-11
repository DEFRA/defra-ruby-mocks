# frozen_string_literal: true

require "securerandom"

module DefraRubyMocks
  class GovpayCreatePaymentService < BaseService

    include CanUseAwsS3

    def run(amount:, description:)
      success_response(amount, description)
    end

    private

    def test_payment_response_status
      response_status(response_status_filename: "test_payment_response_status", default_status: "created")
    end

    def base_url
      File.join(DefraRubyMocks.configuration.govpay_mocks_internal_root_url, "/payments")
    end

    def payment_id
      @payment_id ||= SecureRandom.alphanumeric(26)
    end

    def return_url
      "#{DefraRubyMocks.configuration.govpay_mocks_internal_root_url}/payments/secure/next-url-uuid-abc123"
    end

    def next_url
      "#{DefraRubyMocks.configuration.govpay_mocks_external_root_url_other}/payments/secure/next-url-uuid-abc123"
    end

    def url_root(url)
      uri = URI.parse(url)
      url_root = "#{uri.scheme}://#{uri.host}"
      url_root += ":#{uri.port}" if uri.port.present? && uri.port != 80

      url_root
    end

    # rubocop:disable Metrics/MethodLength
    def success_response(amount, description)
      {
        created_date: "2020-03-03T16:17:19.554Z",
        state: {
          status: test_payment_response_status,
          finished: false
        },
        _links: {
          self: {
            href: "#{base_url}/#{payment_id}",
            method: "GET"
          },
          next_url: {
            href: next_url,
            method: "GET"
          }
        },
        amount: amount.to_i,
        reference: "12345",
        description:,
        return_url:,
        payment_id:,
        payment_provider: "worldpay",
        provider_id: "10987654321"
      }
    end
    # rubocop:enable Metrics/MethodLength

  end
end
