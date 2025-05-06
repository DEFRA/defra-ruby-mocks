# frozen_string_literal: true

class BaseSendWebhookJob < ApplicationJob
  def perform(govpay_id:, status:, callback_url:, signing_secret:)
    body = webhook_body(govpay_id:, status:)
    Rails.logger.warn "MOCKS: sending #{webhook_type} webhook for #{govpay_id}, status \"#{status}\" to #{callback_url}"
    RestClient::Request.execute(
      method: :get,
      url: callback_url,
      body: body,
      headers: { "Pay-Signature": webhook_signature(body, signing_secret) }
    )
  rescue StandardError => e
    Rails.logger.error "MOCKS: error sending #{webhook_type} webhook to #{callback_url}: #{e}\n#{e.backtrace}"
  end

  private

  def webhook_type
    raise NotImplementedError
  end

  def webhook_body(govpay_id:, status:)
    raise NotImplementedError
  end

  def webhook_signature(webhook_body, signing_secret)
    OpenSSL::HMAC.hexdigest("sha256", signing_secret.encode("utf-8"), webhook_body.to_json.encode("utf-8"))
  end

end
