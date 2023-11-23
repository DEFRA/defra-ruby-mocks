# frozen_string_literal: true

require "rails_helper"

module DefraRubyMocks
  RSpec.describe "Officers" do
    after(:all) { Helpers::Configuration.reset_for_tests } # rubocop:disable RSpec/BeforeAfterAll

    let(:path) {  "/defra_ruby_mocks/company/company-no/officers" }

    context "when mocks are enabled" do
      before do
        Helpers::Configuration.prep_for_tests

        get path
      end

      it "returns a JSON response" do
        expect(response.media_type).to eq("application/json")
      end

      it "returns HTTP success response" do
        expect(response).to have_http_status(:ok)
      end

      it "includes the expected JSON payload" do
        expect(JSON.parse(response.body).deep_symbolize_keys[:items][0]).to eq(
          { name: "APPLE, Alice",
            officer_role: "director" }
        )
      end
    end

    context "when mocks are disabled" do
      before(:all) { DefraRubyMocks.configuration.enable = false } # rubocop:disable RSpec/BeforeAfterAll

      it "cannot load the page" do
        expect { get path }.to raise_error(ActionController::RoutingError)
      end
    end
  end
end
