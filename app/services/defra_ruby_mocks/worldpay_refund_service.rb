# frozen_string_literal: true

module DefraRubyMocks
  class WorldpayRefundService < BaseService
    def run(merchant_code:, xml:)
      {
        merchant_code: merchant_code,
        order_code: extract_order_code(xml),
        refund_value: extract_refund_value(xml),
        currency_code: extract_currency_code(xml),
        exponent: extract_exponent(xml)
      }
    end

    private

    def extract_order_code(xml)
      order_modification = xml.at_xpath("//orderModification")
      order_modification.attribute("orderCode").text
    end

    def extract_refund_value(xml)
      amount = xml.at_xpath("//amount")
      amount.attribute("value").text
    end

    def extract_currency_code(xml)
      amount = xml.at_xpath("//amount")
      amount.attribute("currencyCode").text
    end

    def extract_exponent(xml)
      amount = xml.at_xpath("//amount")
      amount.attribute("exponent").text
    end
  end
end
