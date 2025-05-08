# frozen_string_literal: true

require "active_support/concern"

module DefraRubyMocks
  module CanUseAwsS3

    extend ActiveSupport::Concern

    DEFAULT_LAST_REFUND_REQUEST_TIME = 1.day.ago.freeze

    included do

      def s3_bucket_name
        @s3_bucket_name ||= ENV.fetch("AWS_DEFRA_RUBY_MOCKS_BUCKET", nil)
      end

      def set_response_status(response_status_filename:, status:)
        Rails.logger.info "[DefraRubyMocks] [AwsS3] Setting #{response_status_filename} status to \"#{status}\""

        AwsBucketService.write(s3_bucket_name, response_status_filename, status)
      end

      # Check whether a non-default status value has been requested
      def response_status(response_status_filename:, default_status:)
        status = AwsBucketService.read(s3_bucket_name, response_status_filename)
        Rails.logger.warn "[DefraRubyMocks] [AwsS3] read #{response_status_filename}: \"#{status}\""

        status || default_status
      rescue StandardError => e
        # This is expected behaviour when the status default override file is not present.
        Rails.logger.warn "[DefraRubyMocks] [AwsS3] failed to read #{response_status_filename}: #{e}"

        default_status
      end

      # let the refund details service know how long since the refund was requested
      def write_refund_requested_timestamp(timestamp_file_name:)
        Rails.logger.warn "[DefraRubyMocks] [AwsS3] storing timestamp_file_name timestamp"
        AwsBucketService.write(s3_bucket_name, timestamp_file_name, Time.zone.now.to_s)
      end

      def refund_request_timestamp(timestamp_file_name:)
        timestamp = AwsBucketService.read(s3_bucket_name, timestamp_file_name)
        timestamp ? Time.parse(timestamp) : DEFAULT_LAST_REFUND_REQUEST_TIME
      rescue StandardError
        DEFAULT_LAST_REFUND_REQUEST_TIME
      end
    end
  end
end
