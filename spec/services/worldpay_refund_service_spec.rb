# frozen_string_literal: true

require "rails_helper"

module DefraRubyMocks
  RSpec.describe WorldpayRefundService do
    describe ".run" do

      let(:merchant_code) { "MERCHME" }
      let(:args) { { merchant_code: merchant_code, xml: xml } }

      context "when the XML is valid" do

        let(:xml) { Nokogiri::XML(File.read("spec/fixtures/files/worldpay/refund_request_valid.xml")) }

        context "the result it returns" do
          it "is a hash" do
            expect(described_class.run(args)).to be_an_instance_of(Hash)
          end

          it "contains 5 values" do
            result = described_class.run(args).length
            expect(result).to eq(5)
          end

          it "has the merchant code passed in" do
            result = described_class.run(args)[:merchant_code]

            expect(result).to eq(merchant_code)
          end

          it "has an order code extracted from the XML" do
            result = described_class.run(args)[:order_code]

            expect(result).to eq("1579644835")
          end

          it "has the refund value extracted from the XML" do
            result = described_class.run(args)[:refund_value]

            expect(result).to eq("2500")
          end

          it "has a currency code extracted from the XML" do
            result = described_class.run(args)[:currency_code]

            expect(result).to eq("GBP")
          end

          it "has the exponent extracted from the XML" do
            result = described_class.run(args)[:exponent]

            expect(result).to eq("2")
          end
        end

      end

      context "when the XML is invalid" do
        let(:xml) { Nokogiri::XML(File.read("spec/fixtures/files/worldpay/refund_request_invalid.xml")) }

        it "raises an error" do
          expect { described_class.run(args) }.to raise_error StandardError
        end
      end
    end
  end
end
