# frozen_string_literal: true

require "rails_helper"

module DefraRubyMocks
  RSpec.describe "GovpayTestHelpers" do
    let(:base_mocks_url) { File.join(DefraRubyMocks.configuration.govpay_domain, "/govpay/v1/payments") }

    context "when mocks are enabled" do
      let(:aws_bucket_service) { instance_double(AwsBucketService) }

      before do
        Helpers::Configuration.prep_for_tests

        DefraRubyMocks.configure do |config|
          config.govpay_domain = "http://localhost:3000/defra_ruby_mocks"
        end

        allow(AwsBucketService).to receive(:new).and_return(aws_bucket_service)
        allow(aws_bucket_service).to receive(:read)
        allow(aws_bucket_service).to receive(:write)
        allow(aws_bucket_service).to receive(:remove)
      end

      # This is just a test helper, so just confirm that it attempts to write to S3
      describe "#set_test_payment_response_status" do
        before { get "/defra_ruby_mocks/govpay/v1/payments/set_test_payment_response_status/submitted" }

        it { expect(aws_bucket_service).to have_received(:write) }
      end

      # This is just a test helper, so just confirm that it attempts to write to S3
      describe "#set_test_refund_response_status" do
        before { get "/defra_ruby_mocks/govpay/v1/payments/set_test_refund_response_status/submitted" }

        it { expect(aws_bucket_service).to have_received(:write) }
      end

      describe "#send_payment_webhook" do
        let(:request_mock_webhook_path) { "/defra_ruby_mocks/govpay/v1/payments/#{SecureRandom.hex(22)}/send_payment_webhook" }
        let(:params) do
          {
            govpay_id: SecureRandom.hex(22),
            payment_status: "success",
            callback_url: Faker::Internet.url,
            signing_secret: SecureRandom.hex(16)
          }
        end

        let(:response_json) { JSON.parse(response.body) }

        it "returns HTTP 200" do
          post request_mock_webhook_path, params: params

          expect(response).to have_http_status(:ok)
        end

        it "enqueues a job" do
          expect { post request_mock_webhook_path, params: params }.to have_enqueued_job(SendPaymentWebhookJob)
        end
      end

      describe "#send_refund_webhook" do
        let(:request_mock_webhook_path) { "/defra_ruby_mocks/govpay/v1/payments/#{SecureRandom.hex(22)}/send_refund_webhook" }
        let(:params) do
          {
            govpay_id: SecureRandom.hex(22),
            refund_status: "success",
            callback_url: Faker::Internet.url,
            signing_secret: SecureRandom.hex(16)
          }
        end

        let(:response_json) { JSON.parse(response.body) }

        it "returns HTTP 200" do
          post request_mock_webhook_path, params: params

          expect(response).to have_http_status(:ok)
        end

        it "enqueues a job" do
          expect { post request_mock_webhook_path, params: params }.to have_enqueued_job(SendRefundWebhookJob)
        end
      end
    end

    context "when mocks are disabled" do
      before { DefraRubyMocks.configuration.enable = false }

      let(:payment_id) { Faker::Alphanumeric.alphanumeric(number: 26) }

      context "with GET #set_test_payment_response_status" do
        let(:path) { "/defra_ruby_mocks/govpay/v1/payments/set_test_payment_response_status/submitted" }

        it "cannot load the page" do
          expect { post path }.to raise_error(ActionController::RoutingError)
        end
      end

      context "with GET #set_test_refund_response_status" do
        let(:path) { "/defra_ruby_mocks/govpay/v1/payments/set_test_refund_response_status/submitted" }

        it "cannot load the page" do
          expect { get path }.to raise_error(ActionController::RoutingError)
        end
      end

      describe "with #send_payment_webhook" do
        let(:path) { "/defra_ruby_mocks/govpay/v1/payments/#{SecureRandom.hex(22)}/send_payment_webhook" }

        it "cannot load the page" do
          expect { post path }.to raise_error(ActionController::RoutingError)
        end
      end

      describe "with #send_refund_webhook" do
        let(:path) { "/defra_ruby_mocks/govpay/v1/payments/#{SecureRandom.hex(22)}/send_refund_webhook" }

        it "cannot load the page" do
          expect { post path }.to raise_error(ActionController::RoutingError)
        end
      end
    end
  end
end
