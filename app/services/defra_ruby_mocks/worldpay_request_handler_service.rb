# frozen_string_literal: true

module DefraRubyMocks
  class WorldpayRequestHandlerService < BaseService
    def run(xml)
      response = if payment_request?(xml)
                   WorldpayPaymentService.run(
                     merchant_code: extract_merchant_code(xml),
                     xml: xml
                   )
                 end

      response
    end

    private

    def extract_merchant_code(xml)
      payment_service = xml.at_xpath("//paymentService")
      payment_service.attribute("merchantCode").text
    end

    def payment_request?(xml)
      submit = xml.at_xpath("//submit")

      !submit.nil?
    end
  end
end
