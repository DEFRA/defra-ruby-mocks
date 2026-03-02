# frozen_string_literal: true

require "rails_helper"

module DefraRubyMocks
  RSpec.describe "OsPlaces" do
    let(:path) { "/defra_ruby_mocks/places/v1/postcode" }

    context "when mocks are enabled" do
      before { Helpers::Configuration.prep_for_tests }

      context "when the postcode has mock addresses" do
        let(:postcode) { "BS1 5AH" }

        before { get path, params: { postcode: postcode } }

        it "returns a JSON response" do
          expect(response.media_type).to eq("application/json")
        end

        it "returns a 200 code" do
          expect(response).to have_http_status(:ok)
        end

        it "returns results wrapped in OS Places API format", :aggregate_failures do
          parsed = JSON.parse(response.body)
          expect(parsed).to have_key("results")
          expect(parsed["results"]).to be_an(Array)
          expect(parsed["results"].length).to eq(2)
        end

        it "returns addresses in DPA format with expected data" do
          parsed = JSON.parse(response.body)
          dpa = parsed["results"].first["DPA"]
          expect(dpa).to include(
            "UPRN" => "340116", "POST_TOWN" => "BRISTOL", "POSTCODE" => "BS1 5AH"
          )
        end
      end

      context "when the postcode is lowercase with spaces" do
        let(:postcode) { "bs1 5ah" }

        before { get path, params: { postcode: postcode } }

        it "normalizes the postcode and returns results" do
          parsed = JSON.parse(response.body)
          expect(parsed["results"].length).to eq(2)
        end
      end

      context "when the postcode is not in the mock data" do
        let(:postcode) { "SW1A 1AA" }

        before { get path, params: { postcode: postcode } }

        it "returns a JSON response" do
          expect(response.media_type).to eq("application/json")
        end

        it "returns a 200 code" do
          expect(response).to have_http_status(:ok)
        end

        it "returns an empty results array" do
          parsed = JSON.parse(response.body)
          expect(parsed).to eq("results" => [])
        end
      end
    end

    context "when mocks are disabled" do
      before { DefraRubyMocks.configuration.enable = false }

      let(:postcode) { "BS1 5AH" }

      it "cannot load the page" do
        expect { get path, params: { postcode: postcode } }.to raise_error(ActionController::RoutingError)
      end
    end
  end
end
