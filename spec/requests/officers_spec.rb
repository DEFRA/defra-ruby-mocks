# frozen_string_literal: true

require "rails_helper"

module DefraRubyMocks
  RSpec.describe "Officers", type: :request do
    after(:all) { Helpers::Configuration.reset_for_tests }

    let(:path) {  "/defra_ruby_mocks/company/company-no/officers" }

    context "when mocks are enabled" do
      before(:each) { Helpers::Configuration.prep_for_tests }

      it "returns a JSON response" do
        get path

        expect(response.media_type).to eq("application/json")
        expect(response.code).to eq("200")

        expect(JSON.parse(response.body).deep_symbolize_keys[:items][0]).to eq(
          {
            name: "APPLE, Alice",
            officer_role: "director"
          }
        )
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
