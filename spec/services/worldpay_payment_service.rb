# frozen_string_literal: true

require "rails_helper"

module DefraRubyMocks
  RSpec.describe WorldpayRequestService do
    describe ".run" do
      after(:each) { Helpers::Configuration.reset_for_tests }

      context "when the mocks config is missing a worldpay domain" do
        it "raises a 'InvalidConfigError'" do
          expect { described_class.run(nil) }.to raise_error InvalidConfigError
        end
      end

      context "when the XML data is valid" do
        before(:each) do
          DefraRubyMocks.configure do |config|
            config.worldpay_domain = "http://localhost:3000/defra_ruby_mocks"
          end
        end

        let(:data) { File.read("spec/fixtures/payment_request_valid.xml") }

        context "the result it returns" do
          it "is a hash" do
            expect(described_class.run(data)).to be_an_instance_of(Hash)
          end

          it "contains 4 values" do
            result = described_class.run(data).length
            expect(result).to eq(4)
          end

          context "has values extracted from the XML data" do
            it "a merchant code" do
              result = described_class.run(data)[:merchant_code]

              expect(result).to eq("MERCHME")
            end

            it "an order code" do
              result = described_class.run(data)[:order_code]

              expect(result).to eq("1577726052")
            end
          end

          context "has a generated ID which is" do
            it "10 characters long" do
              result = described_class.run(data)[:id]

              expect(result.length).to eq(10)
            end

            it "only made up of the digits 0 to 9" do
              result = described_class.run(data)[:id]

              expect(result.scan(/\D/).empty?).to be_truthy
            end

            it "different each time" do
              results = []
              3.times do
                results << described_class.run(data)[:id]
              end

              expect(results.uniq.length).to eq(results.length)
            end
          end

          context "has a url" do
            it "based on the configured domain, and extracted merchant and order codes" do
              result = described_class.run(data)[:url]

              expect(result).to eq("http://localhost:3000/defra_ruby_mocks/worldpay/dispatcher?OrderKey=MERCHME%5E1577726052")
            end
          end
        end

      end

      context "when the data is invalid" do
        let(:data) { File.read("spec/fixtures/worldpay_request_invalid.xml") }

        it "raises an error" do
          expect { described_class.run(data) }.to raise_error StandardError
        end
      end
    end
  end
end
