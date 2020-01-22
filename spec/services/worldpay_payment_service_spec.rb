# frozen_string_literal: true

require "rails_helper"

module DefraRubyMocks
  RSpec.describe WorldpayPaymentService do
    describe ".run" do
      after(:each) { Helpers::Configuration.reset_for_tests }

      let(:merchant_code) { "MERCHME" }
      let(:args) { { merchant_code: merchant_code, xml: xml } }

      context "when the mocks config is missing a worldpay domain" do
        let(:xml) { nil }

        it "raises a 'InvalidConfigError'" do
          expect { described_class.run(args) }.to raise_error InvalidConfigError
        end
      end

      context "when the XML is valid" do
        before(:each) do
          DefraRubyMocks.configure do |config|
            config.worldpay_domain = "http://localhost:3000/defra_ruby_mocks"
          end
        end

        let(:xml) { Nokogiri::XML(File.read("spec/fixtures/payment_request_valid.xml")) }

        context "the result it returns" do
          it "is a hash" do
            expect(described_class.run(args)).to be_an_instance_of(Hash)
          end

          it "contains 4 values" do
            result = described_class.run(args).length
            expect(result).to eq(4)
          end

          it "has the merchant code passed in" do
            result = described_class.run(args)[:merchant_code]

            expect(result).to eq(merchant_code)
          end

          it "has an order code extracted from the XML" do
            result = described_class.run(args)[:order_code]

            expect(result).to eq("1577726052")
          end

          context "has a generated ID which is" do
            it "10 characters long" do
              result = described_class.run(args)[:id]

              expect(result.length).to eq(10)
            end

            it "only made up of the digits 0 to 9" do
              result = described_class.run(args)[:id]

              expect(result.scan(/\D/).empty?).to be_truthy
            end

            it "different each time" do
              results = []
              3.times do
                results << described_class.run(args)[:id]
              end

              expect(results.uniq.length).to eq(results.length)
            end
          end

          context "has a url" do
            it "based on the configured domain, and extracted merchant and order codes" do
              result = described_class.run(args)[:url]

              expect(result).to eq("http://localhost:3000/defra_ruby_mocks/worldpay/dispatcher?OrderKey=MERCHME%5E1577726052")
            end
          end
        end

      end

      context "when the XML is invalid" do
        let(:xml) { Nokogiri::XML(File.read("spec/fixtures/payment_request_invalid.xml")) }

        it "raises an error" do
          expect { described_class.run(args) }.to raise_error StandardError
        end
      end
    end
  end
end
