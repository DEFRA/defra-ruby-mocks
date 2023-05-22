# frozen_string_literal: true

module DefraRubyMocks
  class GovpayRefundDetailsService < BaseService

    def run(payment_id:, refund_id:) # rubocop:disable Lint/UnusedMethodArgument
      {
        "amount": 2000,
        "created_date": "2019-09-19T16:53:03.213Z",
        "refund_id": "j6se0f2o427g28g8yg3u3i",
        "status": status,
        "settlement_summary": {
          "settled_date": "2019-09-21"
        }
      }
    end

    private

    # "submitted" for up to GOVPAY_REFUND_SUBMITTED_SUCCESS_LAG seconds after the last refund request, then "success"
    def status
      timestamp = File.read("#{Dir.tmpdir}/govpay_request_refund_service_last_run_time")
      last_refund_time = timestamp ? Time.parse(timestamp) : 1.day.ago
      submitted_success_lag = ENV.fetch("GOVPAY_REFUND_SUBMITTED_SUCCESS_LAG", 0).to_i
      cutoff_time = (last_refund_time + submitted_success_lag.seconds).to_time
      return "success" if submitted_success_lag.zero?

      Time.zone.now < cutoff_time ? "submitted" : "success"
    rescue Errno::ENOENT
      write_timestamp_file("govpay_request_refund_service_last_run_time")

      "success"
    end

    def write_timestamp_file(filename)
      filepath = "#{Dir.tmpdir}/#{filename}"

      # FileUtils.touch seems unreliable in VM so need to write/read the actual time
      File.write(filepath, Time.zone.now)
    end

  end
end
