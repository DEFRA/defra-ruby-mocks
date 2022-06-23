# frozen_string_literal: true

require "securerandom"

module DefraRubyMocks
  class GovpayGetPaymentService < BaseService

    def run(payment_id:, amount: Random.rand(100..1_000), created_at: Time.current)
      {
        created_date: created_at,
        amount: amount,
        state: {
          status: "success",
          finished: true
        },
        description: "Your waste carriers registration fee",
        reference: "12345",
        language: "en",
        payment_id: payment_id,
        refund_summary: {
          status: "available",
          amount_available: amount - 100,
          amount_submitted: 0
        },
        total_amount: amount,
        payment_provider: "worldpay",
        provider_id: "10987654321"
      }    
    end

  end
end
