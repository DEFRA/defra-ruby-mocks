# frozen_string_literal: true

module DefraRubyMocks
  class GovpayRequestRefundService < BaseService

    include CanUseAwsS3

    def run(payment_id:, amount:, refund_amount_available:) # rubocop:disable Lint/UnusedMethodArgument
      write_refund_requested_timestamp(timestamp_file_name:)

      {
        amount: amount,
        created_date: "2019-09-19T16:53:03.213Z",
        refund_id: SecureRandom.hex(22),
        status: test_refund_response_status
      }
    end

    private

    def test_refund_response_status
      response_status(response_status_filename: "test_refund_response_status", default_status: "submitted")
    end

    def timestamp_file_name
      @timestamp_file_name = "govpay_request_refund_service_last_run_time"
    end
  end
end
