# frozen_string_literal: true

class SendPaymentWebhookJob < BaseSendWebhookJob

  private

  def webhook_type
    "payment"
  end

  def webhook_body(govpay_id:, status:)
    webhook_body ||= JSON.parse(File.read("lib/fixtures/files/govpay/webhook_payment_update_body.json"))

    webhook_body["resource"]["payment_id"] = govpay_id
    webhook_body["resource"]["state"]["status"] = status

    webhook_body
  end
end
