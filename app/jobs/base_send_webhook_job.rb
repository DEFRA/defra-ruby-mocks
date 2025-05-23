# frozen_string_literal: true

class BaseSendWebhookJob < ApplicationJob
  def perform(govpay_id:, status:, callback_url:, signing_secret:)
    body = webhook_body(govpay_id:, status:)
    Rails.logger.warn "[DefraRubyMocks] [BaseSendWebhookJob] sending #{webhook_type} webhook " \
                      "for #{govpay_id}, status \"#{status}\" to #{callback_url}"
    RestClient::Request.execute(
      method: :post,
      url: callback_url,
      payload: body.to_json,
      headers: { "Pay-Signature": webhook_signature(body, signing_secret) }
    )
  rescue StandardError => e
    Rails.logger.error "[DefraRubyMocks] [BaseSendWebhookJob] error sending  " \
                       "#{webhook_type} webhook to #{callback_url}: #{e}"
  end

  private

  def webhook_type
    raise NotImplementedError
  end

  def webhook_body(govpay_id:, status:)
    raise NotImplementedError
  end

  def webhook_signature(webhook_body, signing_secret)
    digest = OpenSSL::Digest.new("sha256")
    OpenSSL::HMAC.hexdigest(digest, signing_secret, webhook_body.to_json)
  end

end
