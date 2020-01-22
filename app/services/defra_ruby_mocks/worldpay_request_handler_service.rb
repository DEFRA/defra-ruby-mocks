# frozen_string_literal: true

module DefraRubyMocks
  class WorldpayRequestHandlerService < BaseService
    def run(xml)
      arguments = {
        merchant_code: extract_merchant_code(xml),
        xml: xml
      }

      generate_response(arguments)
    end

    private

    def extract_merchant_code(xml)
      payment_service = xml.at_xpath("//paymentService")
      payment_service.attribute("merchantCode").text
    end

    def generate_response(arguments)
      return WorldpayPaymentService.run(arguments) if payment_request?(arguments[:xml])
      return WorldpayRefundService.run(arguments) if refund_request?(arguments[:xml])

      raise UnrecognisedWorldpayRequestError
    end

    def payment_request?(xml)
      submit = xml.at_xpath("//submit")

      !submit.nil?
    end

    def refund_request?(xml)
      modify = xml.at_xpath("//modify")

      !modify.nil?
    end
  end
end
