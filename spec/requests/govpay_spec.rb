# frozen_string_literal: true

require "rails_helper"

module DefraRubyMocks
  RSpec.describe "Govpay" do
    let(:base_mocks_url) { File.join(DefraRubyMocks.configuration.govpay_domain, "/govpay/v1/payments") }

    context "when mocks are enabled" do
      let(:aws_bucket_service) { instance_double(AwsBucketService) }

      before do
        Helpers::Configuration.prep_for_tests

        DefraRubyMocks.configure do |config|
          config.govpay_domain = "http://localhost:3000/defra_ruby_mocks"
        end

        allow(AwsBucketService).to receive(:new).and_return(aws_bucket_service)
        allow(aws_bucket_service).to receive(:write)
        allow(aws_bucket_service).to receive(:read)
      end

      describe "#create_payment" do
        let(:path) { base_mocks_url }
        # Use an example from the Govpay documentation
        let(:payment_request) do
          {
            amount: 14_500,
            reference: "12345",
            description: "Pay your council tax",
            return_url: "https://your.service.gov.uk/completed"
          }
        end

        before { allow(aws_bucket_service).to receive(:write) }

        context "when the request is valid" do
          let(:response_json) { JSON.parse(response.body) }

          before { post path, params: payment_request.as_json }

          it "returns a valid success response" do
            aggregate_failures do
              expect(response.media_type).to eq("application/json")
              expect(response).to have_http_status(:ok)
            end
          end

          it "returns the expected payload values" do
            expect(response_json).to include(
              "reference" => payment_request[:reference],
              "amount" => payment_request[:amount],
              "description" => payment_request[:description]
            )
          end

          it "returns the correct next_url value" do
            expect(response_json["_links"]["next_url"]["href"])
              .to eq File.join(DefraRubyMocks.configuration.govpay_domain, "/payments/secure/next-url-uuid-abc123")
          end

          it "writes the response URL to AWS S3" do
            expect(aws_bucket_service).to have_received(:write).with(anything, anything, payment_request[:return_url])
          end
        end

        describe "#next_url" do
          let(:path) { "#{base_mocks_url}/secure/123" }
          let(:return_url) { Faker::Internet.url }

          before do
            allow(aws_bucket_service).to receive(:read).and_return(return_url)

            get path
          end

          it "redirects to the correct URL" do
            expect(response).to redirect_to return_url
          end

          it "reads the response URL from AWS S3" do
            expect(aws_bucket_service).to have_received(:read)
          end

        end

        context "when the request is missing a mandatory parameter" do
          before { payment_request[:amount] = nil }

          it "returns a HTTP 500 response" do
            post path, params: payment_request.as_json

            expect(response).to have_http_status :internal_server_error
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

            expect(response).to have_http_status :ok
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

            expect(response).to have_http_status :unprocessable_entity
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

            expect(response).to have_http_status :internal_server_error
          end
        end

        context "with a valid request" do
          it "returns a valid success response" do
            post path, params: refund_request.as_json

            expect(response).to have_http_status :ok
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

            expect(response).to have_http_status :ok
          end
        end
      end
    end

    context "when mocks are disabled" do
      before { DefraRubyMocks.configuration.enable = false }

      let(:payment_id) { Faker::Alphanumeric.alphanumeric(number: 26) }

      context "with POST #govpay_payments" do
        let(:path) { "/defra_ruby_mocks/govpay/payments" }

        it "cannot load the page" do
          expect { post path }.to raise_error(ActionController::RoutingError)
        end
      end

      context "with GET #govpay_payments" do
        let(:path) { "/defra_ruby_mocks/govpay/payments/#{payment_id}" }

        it "cannot load the page" do
          expect { get path }.to raise_error(ActionController::RoutingError)
        end
      end

      describe "with #govpay_refunds" do
        let(:path) { "/defra_ruby_mocks/govpay/#{payment_id}/refunds" }

        it "cannot load the page" do
          expect { post path }.to raise_error(ActionController::RoutingError)
        end
      end
    end
  end
end
