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
              get path, {}, "RAW_POST_DATA" => data

              expect(response.content_type).to eq("application/xml")
              expect(response.code).to eq("200")
              expect(response.body).to be_xml
            end
          end

          context "and the request is invalid" do
            let(:data) { File.read("spec/fixtures/payment_request_invalid.xml") }

            it "returns a response with a 500 code" do
              get path, {}, "RAW_POST_DATA" => data

              expect(response.code).to eq("500")
            end
          end
        end

        context "when a refund request is received" do
          context "and the request is valid" do
            let(:data) { File.read("spec/fixtures/refund_request_valid.xml") }

            it "returns an XML response with a 200 code" do
              get path, {}, "RAW_POST_DATA" => data

              expect(response.content_type).to eq("application/xml")
              expect(response.code).to eq("200")
              expect(response.body).to be_xml
            end
          end
        end
      end

      context "#dispatcher" do
        let(:service_response) { double(:response, url: response_url) }
        let(:path) { "/defra_ruby_mocks/worldpay/dispatcher?successURL=#{CGI.escape(success_url)}" }

        context "and the request is valid" do
          before(:each) { allow(WorldpayResponseService).to receive(:run) { service_response } }

          let(:success_url) { "http://example.com/fo/12345/worldpay/success" }

          context "and a response is expected" do

            let(:response_url) { "#{success_url}?#{response_params}" }
            let(:response_params) { "orderKey=admincode1^^987654&paymentStatus=AUTHORISED&paymentAmount=10500&paymentCurrency=GBP&mac=0ba5271e1ed1b26f9bb428ef7fb536a4&source=WP" }

            it "redirects the user with a 300 code" do
              get path

              expect(response).to redirect_to("#{success_url}?#{response_params}")
              expect(response.code).to eq("302")
            end
          end

          context "and a response is not expected" do
            let(:response_url) { "" }

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
