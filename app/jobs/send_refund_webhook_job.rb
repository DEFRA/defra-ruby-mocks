# frozen_string_literal: true

class SendRefundWebhookJob < ApplicationJob
  def perform(govpay_id:, refund_status:, callback_url:, signing_secret:)
    webhook_body = refund_webhook_body(govpay_id:, refund_status:)
    Rails.logger.warn "+++ mocks sending refund webhook for #{govpay_id}, status \"#{refund_status}\" to #{callback_url}"
    RestClient::Request.execute(
      method: :get,
      url: callback_url,
      body: webhook_body,
      headers: { "Pay-Signature": webhook_signature(webhook_body, signing_secret) }
    )
  rescue StandardError => e
    Rails.logger.error "MOCKS: error sending refund webhook to #{callback_url}: #{e}\n#{e.backtrace}"
  end

  private

  def refund_webhook_body(govpay_id:, refund_status:)
    webhook_body ||= JSON.parse(File.read("lib/fixtures/files/govpay/webhook_refund_update_body.json"))

    webhook_body["payment_id"] = govpay_id
    webhook_body["status"] = refund_status

    webhook_body
  end

  def webhook_signature(webhook_body, signing_secret)
    OpenSSL::HMAC.hexdigest("sha256", signing_secret.encode("utf-8"), webhook_body.to_json.encode("utf-8"))
  end

end
