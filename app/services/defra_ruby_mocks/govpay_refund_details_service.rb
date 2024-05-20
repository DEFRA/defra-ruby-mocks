# frozen_string_literal: true

module DefraRubyMocks
  class GovpayRefundDetailsService < BaseService

    DEFAULT_LAST_REFUND_REQUEST_TIME = 1.day.ago.freeze

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

    # "submitted" for up to GOVPAY_REFUND_SUBMITTED_SUCCESS_LAG seconds after the last refund request, then "success"
    def status
      last_refund_time = refund_request_timestamp
      submitted_success_lag = ENV.fetch("GOVPAY_REFUND_SUBMITTED_SUCCESS_LAG", 0).to_i
      cutoff_time = (last_refund_time + submitted_success_lag.seconds).to_time
      return "success" if submitted_success_lag.zero?

      Time.zone.now < cutoff_time ? "submitted" : "success"
    rescue Errno::ENOENT
      write_timestamp_file

      "success"
    end

    def write_timestamp_file
      timestamp = Time.zone.now
      Rails.logger.warn ":::::: writing timestamp file: #{timestamp}"
      AwsBucketService.write(s3_bucket_name, timestamp_file_name, timestamp)
    end

    def s3_bucket_name
      @s3_bucket_name = ENV.fetch("GOVPAY_MOCKS_BUCKET", "defra-ruby-mocks-s3bkt001")
    end

    def timestamp_file_name
      @govpay_request_refund_service_last_run_time = "govpay_request_refund_service_last_run_time"
    end

    def refund_request_timestamp
      timestamp = AwsBucketService.read(s3_bucket_name, timestamp_file_name)
      timestamp ? Time.parse(timestamp) : DEFAULT_LAST_REFUND_REQUEST_TIME
    rescue StandardError
      DEFAULT_LAST_REFUND_REQUEST_TIME
    end

  end
end
