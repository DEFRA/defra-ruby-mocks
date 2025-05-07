# frozen_string_literal: true

require "securerandom"

module DefraRubyMocks
  class GovpayGetPaymentService < BaseService

    include CanUseAwsS3

    def run(payment_id:, amount: Random.rand(100..1_000), created_at: Time.current)
      # This currently supports only success results:
      response_success.merge(
        {
          created_date: created_at,
          amount: amount,
          payment_id: payment_id,
          total_amount: amount
        }
      )
    end

    private

    def test_payment_response_status
      response_status(response_status_filename: "test_payment_response_status", default_status: "success")
    end

    # rubocop:disable Metrics/MethodLength
    def response_success
      {
        amount: 10_501,
        description: "Waste carrier registration upper tier",
        reference: "12345",
        language: "en",
        metadata: {
          ledger_code: "AB100",
          an_internal_reference_number: 200
        },
        email: "sherlock.holmes@example.com",
        state: {
          status: test_payment_response_status,
          finished: true
        },
        payment_id: "cnnffa1e6s3u9a6n24u2cp527d",
        payment_provider: "sandbox",
        created_date: "2022-05-18T11:52:13.669Z",
        refund_summary: {
          status: "available",
          amount_available: 10_501,
          amount_submitted: 0
        },
        settlement_summary: {
          capture_submit_time: "2022-05-18T11:52:39.172Z",
          captured_date: "2022-05-18"
        },
        card_details: {
          last_digits_card_number: "5100",
          first_digits_card_number: "510510",
          cardholder_name: "Sherlock Holmes",
          expiry_date: "01/24",
          billing_address: {
            line1: "221 Baker Street",
            line2: "Flat b",
            postcode: "NW1 6XE",
            city: "London",
            country: "GB"
          },
          card_brand: "Mastercard",
          card_type: "debit"
        },
        delayed_capture: false,
        moto: false,
        provider_id: "9bb0c2c1-d0c5-4a63-8945-f4240e06f8ae",
        return_url: "https://some-wcr-env.defra.gov.uk/completed",
        authorisation_mode: "web",
        card_brand: "Mastercard",
        _links: {
          self: {
            href: "https://publicapi.payments.service.gov.uk/v1/payments/cnnffa1e6s3u9a6n24u2cp527d",
            method: "GET"
          },
          events: {
            href: "https://publicapi.payments.service.gov.uk/v1/payments/cnnffa1e6s3u9a6n24u2cp527d/events",
            method: "GET"
          },
          refunds: {
            href: "https://publicapi.payments.service.gov.uk/v1/payments/cnnffa1e6s3u9a6n24u2cp527d/refunds",
            method: "GET"
          }
        }
      }
    end
    # rubocop:enable Metrics/MethodLength

  end
end
