# frozen_string_literal: true

module DefraRubyMocks
  class GovpayRequestRefundService < BaseService

    def run(payment_id:, amount:, refund_amount_available:) # rubocop:disable Lint/UnusedMethodArgument
      write_timestamp

      # This currently supports only "submitted" status:
      {
        "amount": amount,
        "created_date": "2019-09-19T16:53:03.213Z",
        "refund_id": "j6se0f2o427g28g8yg3u3i",
        "status": "submitted"
      }
    end

    private

    # let the refund details service know how long since the refund was requested
    def write_timestamp
      filepath = "#{Dir.tmpdir}/govpay_request_refund_service_last_run_time"
      # FileUtils.touch seems unreliable in VM so need to write/read the actual time
      File.write(filepath, Time.zone.now)
    end
  end
end
