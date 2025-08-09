# frozen_string_literal: true

class BaseSendWebhookJob < ApplicationJob
  attr_accessor :govpay_payment_id, :callback_url, :signing_secret

  def post_callback
    body = webhook_body

    RestClient::Request.execute(
      method: :post,
      url: callback_url,
      headers: { "Pay-Signature": webhook_signature(body, signing_secret) },
      payload: body.to_json
    )
  rescue StandardError => e
    Rails.logger.error "[DefraRubyMocks] [BaseSendWebhookJob] error sending  " \
                       "#{webhook_type} webhook to #{callback_url}: #{e}"
  end

  private

  def webhook_type
    raise NotImplementedError
  end

  def webhook_body
    raise NotImplementedError
  end

  def webhook_signature(webhook_body, signing_secret)
    digest = OpenSSL::Digest.new("sha256")
    OpenSSL::HMAC.hexdigest(digest, signing_secret, webhook_body.to_json)
  end

end
