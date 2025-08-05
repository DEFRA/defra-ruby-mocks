# frozen_string_literal: true

class SendPaymentWebhookJob < BaseSendWebhookJob
  attr_accessor :govpay_payment_status

  def perform(govpay_payment_id:, govpay_payment_status:, callback_url:, signing_secret:)
    @govpay_payment_id = govpay_payment_id
    @govpay_payment_status = govpay_payment_status
    @callback_url = callback_url
    @signing_secret = signing_secret

    Rails.logger.warn "[DefraRubyMocks] [SendPaymentWebhookJob] sending #{webhook_type} webhook " \
                      "for #{govpay_payment_id}, status \"#{govpay_payment_status}\" to #{callback_url}"

    post_callback
  end

  private

  def webhook_type
    "payment"
  end

  def webhook_body
    webhook_body ||= JSON.parse(File.read("lib/fixtures/files/govpay/webhook_payment_update_body.json"))

    webhook_body["resource"]["payment_id"] = govpay_payment_id
    webhook_body["resource"]["state"]["status"] = govpay_payment_status

    webhook_body
  end
end
