# frozen_string_literal: true

module DefraRubyMocks
  class GovpayRefundDetailsService < BaseService

    include CanUseAwsS3

    def run(payment_id:, refund_id:) # rubocop:disable Lint/UnusedMethodArgument
      {
        amount: 2000,
        created_date: "2019-09-19T16:53:03.213Z",
        refund_id: refund_id,
        status: status,
        settlement_summary: {
          settled_date: "2019-09-21"
        }
      }
    end

    private

    # Check if a non-default status value has been requested
    def test_refund_response_status
      response_status(response_status_filename: "test_refund_response_status", default_status: "submitted")
    end

    # "submitted" (or other, if default override is in place) for up to GOVPAY_REFUND_SUBMITTED_SUCCESS_LAG
    # seconds after the last refund request, then "success"
    def status
      last_refund_time = refund_request_timestamp(timestamp_file_name:)
      submitted_success_lag = ENV.fetch("GOVPAY_REFUND_SUBMITTED_SUCCESS_LAG", 0).to_i
      cutoff_time = (last_refund_time + submitted_success_lag.seconds).to_time
      return "success" if submitted_success_lag.zero?

      Time.zone.now < cutoff_time ? test_refund_response_status : "success"
    rescue Errno::ENOENT
      write_refund_requested_timestamp(timestamp_file_name:)

      "success"
    end

    def timestamp_file_name
      @govpay_request_refund_service_last_run_time = "govpay_request_refund_service_last_run_time"
    end
  end
end
