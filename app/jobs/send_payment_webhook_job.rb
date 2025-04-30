# frozen_string_literal: true

class SendPaymentWebhookJob < ApplicationJob
  def perform(govpay_id:, payment_status:, callback_url:, signing_secret:)
    webhook_body = payment_webhook_body(govpay_id:, payment_status:)
    RestClient::Request.execute(
      method: :get,
      url: callback_url,
      body: webhook_body,
      headers: { "Pay-Signature": webhook_signature(webhook_body, signing_secret) }
    )
  rescue StandardError => e
    Rails.logger.error "MOCKS: error sending payment webhook to #{callback_url}: #{e}\n#{e.backtrace}"
  end

  private

  def payment_webhook_body(govpay_id:, payment_status:)
    webhook_body ||= JSON.parse(File.read("lib/fixtures/files/govpay/webhook_payment_update_body.json"))

    webhook_body["resource"]["payment_id"] = govpay_id
    webhook_body["resource"]["state"]["status"] = payment_status

    webhook_body
  end

  def webhook_signature(webhook_body, signing_secret)
    OpenSSL::HMAC.hexdigest("sha256", signing_secret.encode("utf-8"), webhook_body.to_json.encode("utf-8"))
  end

end
