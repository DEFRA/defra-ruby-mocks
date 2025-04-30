# frozen_string_literal: true

module DefraRubyMocks
  class GovpayTestHelpersController < ::DefraRubyMocks::ApplicationController

    skip_before_action :verify_authenticity_token

    # These are helpers for the automated acceptance tests.

    # The mock will use the value passed in to populate the status field on all future payments.
    def set_test_payment_response_status
      Rails.logger.info "MOCKS: Setting payment response status to #{params[:status]}"

      AwsBucketService.write(s3_bucket_name, "test_payment_response_status", params[:status])

      head 200
    end

    # The mock will use the value passed in to populate the status field on all future refunds.
    def set_test_refund_response_status
      Rails.logger.info "MOCKS: Setting refund response status to #{params[:status]}"

      AwsBucketService.write(s3_bucket_name, "test_refund_response_status", params[:status])

      head 200
    end

    # This schedules a job to send a mock payment webhook.
    def send_payment_webhook
      Rails.logger.warn "MOCKS: Sending payment webhook for #{params[:govpay_id]}, status #{params[:payment_status]}"
      %w[govpay_id payment_status callback_url signing_secret].each do |p|
        raise StandardError, "Missing parameter: '#{p}'" unless params[p].present?
      end

      SendPaymentWebhookJob.perform_later(
        params[:govpay_id],
        params[:payment_status],
        params[:callback_url],
        params[:signing_secret]
      )

      head 200
    end

    # This schedules a job to send a mock refund webhook.
    def send_refund_webhook
      Rails.logger.warn "MOCKS: Sending refund webhook for #{params[:govpay_id]}, status #{params[:refund_status]}"
      %w[govpay_id refund_status callback_url signing_secret].each do |p|
        raise StandardError, "Missing parameter: '#{p}'" unless params[p].present?
      end

      SendRefundWebhookJob.perform_later(
        params[:govpay_id],
        params[:refund_status],
        params[:callback_url],
        params[:signing_secret]
      )

      head 200
    end

    private

    def s3_bucket_name
      @s3_bucket_name = ENV.fetch("AWS_DEFRA_RUBY_MOCKS_BUCKET", nil)
    end
  end
end
