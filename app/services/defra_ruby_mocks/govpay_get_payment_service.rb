# frozen_string_literal: true

require "securerandom"

module DefraRubyMocks
  class GovpayGetPaymentService < BaseService

    def run(payment_id:, amount: Random.rand(100..1_000), created_at: Time.current)
      response_attributes = {
        created_date: created_at,
        amount: amount,
        payment_id: payment_id,
        total_amount: amount
      }

      case requested_status(payment_id)
      when "failure"
        response_json("failure").merge(amount: amount)
      when "created"
        response_json("created").merge(response_attributes)
      when "cancelled"
        response_json("cancelled").merge(response_attributes)
      when "error"
        response_json("error")
      else
        response_json("success").merge(response_attributes)
      end
    end

    private

    def response_json(status)
      JSON.parse(File.read("spec/fixtures/files/govpay/get_payment_response_#{status}.json"))
    end

    # Allow the consumer to trigger simulated failures by including keywords in the payment id.
    def requested_status(payment_id)
      return "failure" if payment_id.include?("reject")
      return "created" if payment_id.include?("pending")
      return "cancelled" if payment_id.include?("cancel")
      return "error" if payment_id.include?("error")

      "success"
    end
  end
end
