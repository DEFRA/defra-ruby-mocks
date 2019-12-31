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

        context "and the request is valid" do
          let(:data) { File.read("spec/fixtures/worldpay_request_valid.xml") }

          it "returns an XML response with a 200 code" do
            get path, {}, "RAW_POST_DATA" => data

            expect(response.content_type).to eq("application/xml")
            expect(response.code).to eq("200")
          end
        end

        context "and the request is invalid" do
          let(:data) { File.read("spec/fixtures/worldpay_request_invalid.xml") }

          it "returns a response with a 500 code" do
            get path, {}, "RAW_POST_DATA" => data

            expect(response.code).to eq("500")
          end
        end
      end

      context "#dispatcher" do
        let(:path) { "/defra_ruby_mocks/worldpay/dispatcher" }

        context "and the request is valid" do
          it "redirects the user with a 300 code" do
            get path

            expect(response).to redirect_to("/")
            expect(response.code).to eq("302")
          end
        end

        context "and the request is invalid" do
          it "returns a response with a 500 code" do
            get path

            expect(response.code).to eq("500")
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
