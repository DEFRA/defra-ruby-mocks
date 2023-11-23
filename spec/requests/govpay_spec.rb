# frozen_string_literal: true

require "rails_helper"

module DefraRubyMocks
  RSpec.describe "Govpay", type: :request do
    after(:all) { Helpers::Configuration.reset_for_tests }

    context "when mocks are enabled" do
      before(:each) do
        Helpers::Configuration.prep_for_tests
        DefraRubyMocks.configure do |config|
          config.govpay_domain = "http://localhost:3000/defra_ruby_mocks"
        end

      end

      context "#create_payment" do
        let(:path) { "/defra_ruby_mocks/govpay/v1/payments" }
        # Use an example from the Govpay documentation
        let(:payment_request) do
          {
            amount: 14_500,
            reference: "12345",
            description: "Pay your council tax",
            return_url: "https://your.service.gov.uk/completed"
          }
        end

        context "when the request is valid" do

          before { post path, params: payment_request.as_json }

          it "returns a valid success response" do
            aggregate_failures do
              expect(response.media_type).to eq("application/json")
              expect(response.code).to eq("200")
            end
          end

          it "returns the expected payload values" do
            response_json = JSON.parse(response.body)
            aggregate_failures do
              expect(response_json["reference"]).to eq payment_request[:reference]
              expect(response_json["amount"]).to eq payment_request[:amount]
              expect(response_json["description"]).to eq payment_request[:description]
              expect(response_json["_links"]["next_url"]["href"]).to eq File.join(DefraRubyMocks.configuration.govpay_domain, "/payments/secure/next-url-uuid-abc123")
            end
          end
        end

        context "when the request is missing a mandatory parameter" do
          before { payment_request[:amount] = nil }

          it "returns a HTTP 500 response" do
            post path, params: payment_request.as_json

            expect(response.code).to eq "500"
          end
        end
      end

      describe "#payment_details" do
        let(:path) { "/defra_ruby_mocks/govpay/v1/payments/#{payment_id}" }

        context "when the payment id is valid" do
          before do
            allow(GovpayGetPaymentService).to receive(:run)
              .with(payment_id)
              .and_return(JSON.parse(File.read("spec/fixtures/files/govpay/get_payment_response_success.json")))
          end

          let(:payment_id) { "12345678901234567890123456" }

          it "returns a valid success response" do
            get path

            expect(response.code).to eq "200"
          end
        end

        context "when the payment id is not valid" do
          before do
            allow(GovpayGetPaymentService).to receive(:run)
              .with(payment_id)
              .and_return(JSON.parse(File.read("spec/fixtures/files/govpay/get_payment_response_error.json")))
          end

          let(:payment_id) { "0" }

          it "returns a 422 response" do
            get path

            expect(response.code).to eq "422"
          end
        end
      end

      describe "#create_refund" do
        let(:payment_id) { "12345678901234567890123456" }
        let(:path) { "/defra_ruby_mocks/govpay/v1/payments/#{payment_id}/refunds" }
        let(:refund_request) do
          {
            amount: 2000,
            refund_amount_available: 5000
          }
        end

        context "when the request is missing a mandatory parameter" do
          before { refund_request[:refund_amount_available] = nil }

          it "returns a HTTP 500 response" do
            post path, params: refund_request.as_json

            expect(response.code).to eq "500"
          end
        end

        context "with a valid request" do
          it "returns a valid success response" do
            post path, params: refund_request.as_json

            expect(response.code).to eq "200"
          end
        end
      end

      describe "#refund_details" do
        let(:payment_id) { "12345678901234567890123456" }
        let(:refund_id) { "j6se0f2o427g28g8yg3u3i" }
        let(:path) { "/defra_ruby_mocks/govpay/v1/payments/#{payment_id}/refunds/#{refund_id}" }

        context "with a valid request" do
          it "returns a valid success response" do
            get path

            expect(response.code).to eq "200"
          end
        end
      end
    end

    context "when mocks are disabled" do
      before(:each) { DefraRubyMocks.configuration.enable = false }
      let(:payment_id) { Faker::Alphanumeric.alphanumeric(number: 26) }

      context "POST #govpay_payments" do
        let(:path) { "/defra_ruby_mocks/govpay/payments" }

        it "cannot load the page" do
          expect { post path }.to raise_error(ActionController::RoutingError)
        end
      end

      context "GET #govpay_payments" do
        let(:path) { "/defra_ruby_mocks/govpay/payments/#{payment_id}" }

        it "cannot load the page" do
          expect { get path }.to raise_error(ActionController::RoutingError)
        end
      end

      context "#govpay_refunds" do
        let(:path) { "/defra_ruby_mocks/govpay/#{payment_id}/refunds" }

        it "cannot load the page" do
          expect { post path }.to raise_error(ActionController::RoutingError)
        end
      end
    end
  end
end
