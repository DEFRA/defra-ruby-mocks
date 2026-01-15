# frozen_string_literal: true

require "rails_helper"

module DefraRubyMocks
  RSpec.describe OsPlacesService do
    describe ".run" do
      subject(:run_service) { described_class.run(postcode) }

      context "when the postcode has mock addresses" do
        let(:postcode) { "BS1 5AH" }

        it "returns the service instance" do
          expect(run_service).to be_a(described_class)
        end

        it "returns results with mock addresses" do
          aggregate_failures do
            expect(run_service.results).to be_an(Array)
            expect(run_service.results.length).to eq(2)
          end
        end

        it "returns addresses with expected structure" do
          address = run_service.results.first
          expect(address).to include(
            "uprn" => "340116", "town" => "BRISTOL", "postcode" => "BS1 5AH"
          )
        end
      end

      context "when the postcode is lowercase with spaces" do
        let(:postcode) { "bs1 5ah" }

        it "normalizes the postcode and returns results" do
          expect(run_service.results.length).to eq(2)
        end
      end

      context "when the postcode has extra whitespace" do
        let(:postcode) { "  BS1   5AH  " }

        it "normalizes the postcode and returns results" do
          expect(run_service.results.length).to eq(2)
        end
      end

      context "when the postcode is not in the mock data" do
        let(:postcode) { "SW1A 1AA" }

        it "returns an empty array" do
          expect(run_service.results).to eq([])
        end
      end
    end
  end
end
