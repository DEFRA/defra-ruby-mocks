# frozen_string_literal: true

require "rails_helper"

module DefraRubyMocks
  RSpec.describe "OsPlaces" do
    let(:path) { "/defra_ruby_mocks/addresses" }

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

        it "returns an array of addresses" do
          results = JSON.parse(response.body)
          aggregate_failures do
            expect(results).to be_an(Array)
            expect(results.length).to eq(2)
          end
        end

        it "returns addresses with expected data" do
          results = JSON.parse(response.body)
          expect(results.first).to include(
            "uprn" => "340116", "town" => "BRISTOL", "postcode" => "BS1 5AH"
          )
        end
      end

      context "when the postcode is lowercase with spaces" do
        let(:postcode) { "bs1 5ah" }

        before { get path, params: { postcode: postcode } }

        it "normalizes the postcode and returns results" do
          results = JSON.parse(response.body)
          expect(results.length).to eq(2)
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

        it "returns an empty array" do
          results = JSON.parse(response.body)
          expect(results).to eq([])
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
