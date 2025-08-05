# frozen_string_literal: true

class SendRefundWebhookJob < BaseSendWebhookJob
  attr_accessor :govpay_refund_id, :govpay_refund_status

  def perform(govpay_payment_id:, govpay_refund_id:, govpay_refund_status:, callback_url:, signing_secret:)
    @govpay_payment_id = govpay_payment_id
    @govpay_refund_status = govpay_refund_status
    @govpay_refund_id = govpay_refund_id
    @callback_url = callback_url
    @signing_secret = signing_secret

    Rails.logger.warn "[DefraRubyMocks] [SendRefundWebhookJob] sending #{webhook_type} webhook " \
                      "for payment #{govpay_payment_id}, refund #{govpay_refund_id}, status  " \
                      "\"#{govpay_refund_status}\" to #{callback_url}"

    post_callback
  end

  private

  def webhook_type
    "refund"
  end

  def webhook_body
    webhook_body ||= JSON.parse(File.read("lib/fixtures/files/govpay/webhook_refund_update_body.json"))

    webhook_body["refund_id"] = govpay_refund_id
    webhook_body["payment_id"] = govpay_payment_id
    webhook_body["status"] = govpay_refund_status

    webhook_body
  end
end
