# frozen_string_literal: true

module DefraRubyMocks
  class GovpayTestHelpersController < ::DefraRubyMocks::ApplicationController

    skip_before_action :verify_authenticity_token

    include CanUseAwsS3

    # These are helpers for the automated acceptance tests.

    # The mock will use the value passed in to populate the status field on all future payments.
    def set_test_payment_response_status
      set_response_status(response_status_filename: "test_payment_response_status", status: params[:status])

      head 200
    end

    # The mock will use the value passed in to populate the status field on all future refunds.
    def set_test_refund_response_status
      set_response_status(response_status_filename: "test_refund_response_status", status: params[:status])

      head 200
    end

    # This schedules a job to send a mock payment webhook.
    def send_payment_webhook
      Rails.logger.warn "[DefraRubyMocks] [send_payment_webhook] #{params.slice(:govpay_payment_id,
                                                                                :govpay_payment_payment_status)}"

      %w[govpay_payment_id govpay_payment_status callback_url signing_secret].each do |p|
        raise StandardError, "Missing parameter: '#{p}'" unless params[p].present?
      end

      SendPaymentWebhookJob.perform_later(
        govpay_payment_id: params[:govpay_payment_id],
        govpay_payment_status: params[:govpay_payment_status],
        callback_url: params[:callback_url],
        signing_secret: params[:signing_secret]
      )

      head 200
    end

    # This schedules a job to send a mock refund webhook.
    def send_refund_webhook
      Rails.logger.warn "[DefraRubyMocks] [send_refund webhook] #{params.slice(:govpay_refund_id, :govpay_payment_id,
                                                                               :govpay_refund_status)}"

      %w[govpay_payment_id govpay_refund_id govpay_refund_status callback_url signing_secret].each do |p|
        raise StandardError, "Missing parameter: '#{p}'" unless params[p].present?
      end

      SendRefundWebhookJob.perform_later(
        govpay_payment_id: params[:govpay_payment_id],
        govpay_refund_id: params[:govpay_refund_id],
        govpay_refund_status: params[:govpay_refund_status],
        callback_url: params[:callback_url],
        signing_secret: params[:signing_secret]
      )

      head 200
    end

    private

    def s3_bucket_name
      @s3_bucket_name = ENV.fetch("AWS_DEFRA_RUBY_MOCKS_BUCKET", nil)
    end
  end
end
