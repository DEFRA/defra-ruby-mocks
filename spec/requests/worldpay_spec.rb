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

      context "#stuck" do
        let(:path) { "/defra_ruby_mocks/worldpay/stuck" }

        context "when a direct request is made" do
          it "renders the page without debug information and with a 200 code" do
            get path

            expect(response).to render_template(:stuck)
            expect(response.code).to eq("200")
            expect(response.body).to include("Stuck?")
          end
        end

        context "when we redirect to it from the worldpay dispatcher" do
          before(:each) do
            cookies[:defra_ruby_mocks] = {
              supplied_url: supplied_url,
              separator: "?",
              order_key: "ok",
              mac: "mc",
              value: 154_00,
              status: "st",
              reference: "rf",
              url: "ul"
            }.to_json
          end
          let(:supplied_url) { "http://example.com/foobar" }

          it "renders the page with debug information and with a 200 code" do
            get path

            expect(response).to render_template(:stuck)
            expect(response.code).to eq("200")
            expect(response.body).to include("Stuck!")
            expect(response.body).to include(supplied_url)
          end
        end
      end
    end

    context "when mocks are disabled" do
      before(:each) { DefraRubyMocks.configuration.enable = false }

      context "#stuck" do
        let(:path) { "/defra_ruby_mocks/worldpay/stuck" }

        it "cannot load the page" do
          expect { get path }.to raise_error(ActionController::RoutingError)
        end
      end
    end
  end
end
