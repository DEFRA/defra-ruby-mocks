require "rails_helper"

module DefraRubyMocks
  RSpec.describe "Worldpay", type: :request do
    before(:all) do
      DefraRubyMocks.configure do |config|
        config.worldpay_admin_code = "admincode1"
        config.worldpay_mac_secret = "macsecret1"
        config.worldpay_domain = "http://localhost:3000/defra_ruby_mocks"
      end
    end

    context "#payments_service" do
      let(:path) { "/defra_ruby_mocks/worldpay/payments-service" }

      context "when mocks are enabled" do
        before(:all) { Helpers::Configuration.prep_for_tests }
        after(:all) { Helpers::Configuration.reset_for_tests }

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

          it "returns an XML response with a 500 code" do
            get path, {}, "RAW_POST_DATA" => data

            expect(response.content_type).to eq("application/xml")
            expect(response.code).to eq("500")
          end
        end
      end

      context "when mocks are disabled" do
        before(:all) { DefraRubyMocks.configuration.enable = false }

        it "cannot load the page" do
          expect { get path }.to raise_error(ActionController::RoutingError)
        end
      end
    end
  end
end
