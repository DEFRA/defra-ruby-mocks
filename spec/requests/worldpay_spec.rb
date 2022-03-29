# frozen_string_literal: true

require "rails_helper"

module DefraRubyMocks
  RSpec.describe "Worldpay", type: :request do
    after(:all) { Helpers::Configuration.reset_for_tests }

    context "when mocks are enabled" do
      before(:each) do
        Helpers::Configuration.prep_for_tests
        DefraRubyMocks.configure do |config|
          config.worldpay_admin_code = "admincode1"
          config.worldpay_mac_secret = "macsecret1"
          config.worldpay_domain = "http://localhost:3000/defra_ruby_mocks"
        end
      end

      context "#payments_service" do
        let(:path) { "/defra_ruby_mocks/worldpay/payments-service" }

        context "when a payment request is received" do
          context "and the request is valid" do
            let(:data) { File.read("spec/fixtures/payment_request_valid.xml") }

            it "returns an XML response with a 200 code" do
              post path, headers: { "RAW_POST_DATA" => data }

              expect(response.media_type).to eq("application/xml")
              expect(response.code).to eq("200")
              expect(response.body).to be_xml
            end
          end

          context "and the request is invalid" do
            let(:data) { File.read("spec/fixtures/payment_request_invalid.xml") }

            it "returns a response with a 500 code" do
              post path, headers: { "RAW_POST_DATA" => data }

              expect(response.code).to eq("500")
            end
          end
        end

        context "when a refund request is received" do
          context "and the request is valid" do
            let(:data) { File.read("spec/fixtures/refund_request_valid.xml") }

            it "returns an XML response with a 200 code" do
              post path, headers: { "RAW_POST_DATA" => data }

              expect(response.media_type).to eq("application/xml")
              expect(response.code).to eq("200")
              expect(response.body).to be_xml
            end
          end
        end
      end

      context "#dispatcher" do
        let(:success_url) { "http://example.com/fo/12345/worldpay/success" }
        let(:failure_url) { "http://example.com/fo/12345/worldpay/failure" }
        let(:pending_url) { "http://example.com/fo/12345/worldpay/pending" }
        let(:cancel_url) { "http://example.com/fo/12345/worldpay/cancel" }
        let(:error_url) { "http://example.com/fo/12345/worldpay/error" }
        let(:response_url) { "#{success_url}?orderKey=admincode1^^987654&paymentStatus=#{status}&paymentAmount=10500&paymentCurrency=GBP&mac=0ba5271e1ed1b26f9bb428ef7fb536a4&source=WP" }
        let(:path) do
          root = "/defra_ruby_mocks/worldpay/dispatcher"
          escaped_success = CGI.escape(success_url)
          escaped_failure = CGI.escape(failure_url)
          escaped_pending = CGI.escape(pending_url)
          escaped_cancel = CGI.escape(cancel_url)
          escaped_error = CGI.escape(error_url)

          "#{root}?successURL=#{escaped_success}&failureURL=#{escaped_failure}&pendingURL=#{escaped_pending}&cancelURL=#{escaped_cancel}&errorURL=#{escaped_error}"
        end
        let(:service_response) do
          double(
            :response,
            supplied_url: success_url,
            url: response_url,
            status: status,
            separator: "?",
            order_key: "admincode1",
            mac: "e5bc7ce5dfe44d2000771ac2b157f0e9",
            value: 154_00,
            reference: "12345"
          )
        end

        context "and the request is valid" do
          before(:each) do
            allow(WorldpayResponseService).to receive(:run)
              .with(
                success_url: success_url,
                failure_url: failure_url,
                pending_url: pending_url,
                cancel_url: cancel_url,
                error_url: error_url
              ) { service_response }
          end

          context "and a response is expected" do
            let(:status) { "AUTHORISED" }

            it "redirects the user with a 300 code" do
              get path

              expect(response).to redirect_to(response_url)
              expect(response.code).to eq("302")
            end
          end

          context "and a response is not expected" do
            let(:status) { :STUCK }

            it "renders the Worldpay stuck page" do
              get path

              expect(response).to render_template(:stuck)
              expect(response.code).to eq("200")
            end
          end
        end

        context "and the request is invalid" do
          before(:each) { allow(WorldpayResponseService).to receive(:run).and_raise(MissingResourceError.new("foo")) }

          context "because the success url is not in a recognised format" do
            let(:success_url) { "http://example.com/forthewin" }

            it "returns a response with a 500 code" do
              get path

              expect(response.code).to eq("500")
            end
          end
        end
      end
    end

    context "when mocks are disabled" do
      before(:each) { DefraRubyMocks.configuration.enable = false }

      context "#payments_service" do
        let(:path) { "/defra_ruby_mocks/worldpay/payments-service" }

        it "cannot load the page" do
          expect { get path }.to raise_error(ActionController::RoutingError)
        end
      end

      context "#dispatcher" do
        let(:path) { "/defra_ruby_mocks/worldpay/dispatcher" }

        it "cannot load the page" do
          expect { get path }.to raise_error(ActionController::RoutingError)
        end
      end
    end
  end
end
