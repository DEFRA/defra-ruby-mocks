# frozen_string_literal: true

module DefraRubyMocks
  class GovpayRequestRefundService < BaseService

    def run(payment_id:, amount:, refund_amount_available:) # rubocop:disable Lint/UnusedMethodArgument
      write_timestamp

      {
        amount: amount,
        created_date: "2019-09-19T16:53:03.213Z",
        refund_id: SecureRandom.hex(22),
        status: test_refund_response_status
      }
    end

    private

    # Check if a non-default status value has been requested
    def test_refund_response_status
      AwsBucketService.read(s3_bucket_name, "test_refund_response_status") || "submitted"
    rescue StandardError => e
      # This is expected behaviour when the refund status default override file is not present.
      Rails.logger.warn ":::::: mocks failed to read test_refund_response_status: #{e}"
      "submitted"
    end

    # let the refund details service know how long since the refund was requested
    def write_timestamp
      Rails.logger.warn ":::::: storing refund request timestamp"
      AwsBucketService.write(s3_bucket_name, timestamp_file_name, Time.zone.now.to_s)
    end

    def s3_bucket_name
      @s3_bucket_name = ENV.fetch("AWS_DEFRA_RUBY_MOCKS_BUCKET", nil)
    end

    def timestamp_file_name
      @timestamp_file_name = "govpay_request_refund_service_last_run_time"
    end
  end
end
