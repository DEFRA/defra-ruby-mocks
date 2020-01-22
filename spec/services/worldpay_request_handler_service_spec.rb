require "rails_helper"

module DefraRubyMocks
  RSpec.describe WorldpayRequestHandlerService do
    describe ".run" do
      context "when a request is made" do

        let(:merchant_code) { "MERCHME" }
        let(:args) { { merchant_code: merchant_code, xml: xml } }

        context "and it's for a payment" do
          before do
            allow_any_instance_of(WorldpayPaymentService).to receive(:generate_id) { order_id }
          end

          let(:xml) { Nokogiri::XML(File.read("spec/fixtures/payment_request_valid.xml")) }
          let(:order_id) { "1234567890" }
          let(:request_type) { { request_type: :payment } }
          let(:response_values) do
            {
              merchant_code: merchant_code,
              order_code: "1577726052",
              id: order_id,
              url: "http://example.com"
            }
          end

          it "correctly determines the request service to use" do
            expect(WorldpayPaymentService).to receive(:run).with(args) { response_values }

            described_class.run(xml)
          end

          it "returns the values the controller needs to handle the request" do
            expect(WorldpayPaymentService).to receive(:run).with(args) { response_values }

            expect(described_class.run(xml)).to eq(request_type.merge(response_values))
          end
        end

        context "and it's for a refund" do
          let(:xml) { Nokogiri::XML(File.read("spec/fixtures/refund_request_valid.xml")) }
          let(:request_type) { { request_type: :refund } }
          let(:response_values) do
            {
              merchant_code: merchant_code,
              order_code: "1579644835",
              refund_value: "2500",
              currency_code: "GBP",
              exponent: "2"
            }
          end

          it "correctly determines the request service to use" do
            expect(WorldpayRefundService).to receive(:run).with(args) { response_values }

            described_class.run(xml)
          end

          it "returns the values the controller needs to handle the request" do
            expect(WorldpayRefundService).to receive(:run).with(args) { response_values }

            expect(described_class.run(xml)).to eq(request_type.merge(response_values))
          end
        end

        context "but it's not recognised" do
          let(:xml) { Nokogiri::XML(File.read("spec/fixtures/unrecognised_request.xml")) }

          it "raises a 'UnrecognisedWorldpayRequestError'" do
            expect { described_class.run(xml) }.to raise_error UnrecognisedWorldpayRequestError
          end
        end
      end
    end
  end
end
