# frozen_string_literal: true

class SendRefundWebhookJob < BaseSendWebhookJob

  private

  def webhook_type
    "refund"
  end

  def webhook_body(govpay_id:, status:)
    webhook_body ||= JSON.parse(File.read("lib/fixtures/files/govpay/webhook_refund_update_body.json"))

    webhook_body["refund_id"] = govpay_id
    webhook_body["status"] = status

    webhook_body
  end
end
