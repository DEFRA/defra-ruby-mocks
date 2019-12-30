require "rails_helper"

module DefraRubyMocks
  RSpec.describe "Worldpay", type: :request do
    let(:path) { "/defra_ruby_mocks/worldpay" }

    context "when mocks are enabled" do
      before(:all) do
        Helpers::Configuration.prep_for_tests
        DefraRubyMocks.configure do |config|
          config.worldpay_admin_code = "admincode1"
          config.worldpay_mac_secret = "macsecret1"
          config.worldpay_domain = "http://localhost:3000/defra_ruby_mocks"
        end
      end
      after(:all) { Helpers::Configuration.reset_for_tests }

      it "returns an XML response with a 200 code" do
        get path

        expect(response.content_type).to eq("application/xml")
        expect(response.code).to eq("200")
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
