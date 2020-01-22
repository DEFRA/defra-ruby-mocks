require "rails_helper"

module DefraRubyMocks
  RSpec.describe WorldpayRequestHandlerService do
    describe ".run" do
      context "when a request is made" do

        context "and it's for a payment" do
          before do
            allow_any_instance_of(WorldpayPaymentService).to receive(:generate_id) { order_id }
          end

          let(:xml) { Nokogiri::XML(File.read("spec/fixtures/payment_request_valid.xml")) }
          let(:merchant_code) { "MERCHME" }
          let(:order_id) { "1234567890" }
          let(:response_values) do
            {
              merchant_code: merchant_code,
              order_code: "1577726052",
              id: order_id,
              url: "http://example.com"
            }
          end
          let(:args) { { merchant_code: merchant_code, xml: xml } }

          it "correctly determines the request service to use" do
            expect(WorldpayPaymentService).to receive(:run).with(args) { response_values }

            described_class.run(xml)
          end

          it "returns the values the controller needs to handle the request" do
            expect(WorldpayPaymentService).to receive(:run).with(args) { response_values }

            expect(described_class.run(xml)).to eq(response_values)
          end
        end
      end
    end
  end
end
