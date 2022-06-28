# frozen_string_literal: true

module DefraRubyMocks
  class GovpayPaymentCallbackJob < DefraRubyMocks::ApplicationJob
    queue_as :default

    def perform(*response_url)
      Rails.logger.debug "GovpayPaymentCallbackJob calling response URL #{response_url}"
      RestClient::Request.execute(method: :GET, url: response_url)
    rescue RestClient::ExceptionWithResponse => e
      Rails.logger.debug "GovpayPaymentCallbackJob: RestClient received response: #{e}"
    rescue StandardError => e
      Rails.logger.error("GovpayPaymentCallbackJob: Error sending request to govpay: #{e}")
      Airbrake.notify(e, message: "Error on govpay request")
    end
  end
end
