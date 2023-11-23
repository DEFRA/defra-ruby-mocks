# frozen_string_literal: true

require "rails_helper"

module DefraRubyMocks
  RSpec.describe "Company" do
    let(:path) { "/defra_ruby_mocks/company" }

    context "when mocks are enabled" do
      before { Helpers::Configuration.prep_for_tests }

      context "when the company number is 99999999 for not found" do
        let(:company_number) { "99999999" }
        let(:content) { JSON.parse(response.body) }

        before { get "#{path}/#{company_number}" }

        it "returns a JSON response" do
          expect(response.media_type).to eq("application/json")
        end

        it "returns a HTTP 404 code" do
          expect(response).to have_http_status(:not_found)
        end

        it "includes error content" do
          expect(content).to include("errors")
        end
      end

      context "when the company number is from the 'specials' list" do
        let(:company_number) { "05868270" }

        before { get "#{path}/#{company_number}" }

        it "returns a JSON response" do
          expect(response.media_type).to eq("application/json")
        end

        it "returns a 200 code" do
          expect(response).to have_http_status(:ok)
        end

        it "returns a status that isn't 'active'" do
          expect(JSON.parse(response.body).deep_symbolize_keys).to include(company_status: "dissolved")
        end
      end

      context "when the company number is not from the 'specials' list" do
        context "when it is valid" do
          let(:company_number) { "SC247974" }

          before { get "#{path}/#{company_number}" }

          it "returns a JSON response" do
            expect(response.media_type).to eq("application/json")
          end

          it "returns a 200 code" do
            expect(response).to have_http_status(:ok)
          end

          it "returns a status of 'active'" do
            company_status = JSON.parse(response.body)["company_status"]
            expect(company_status).to eq("active")
          end

          it "returns a compamy_type of 'ltd'" do
            company_type = JSON.parse(response.body)["type"]
            expect(company_type).to eq("ltd")
          end
        end

        context "when it is not valid" do
          let(:company_number) { "foo" }
          let(:content) { JSON.parse(response.body) }

          before { get "#{path}/#{company_number}" }

          it "returns a JSON response" do
            expect(response.media_type).to eq("application/json")
          end

          it "returns a HTTP 404 code" do
            expect(response).to have_http_status(:not_found)
          end

          it "includes error content" do
            expect(content).to include("errors")
          end
        end
      end
    end

    context "when mocks are disabled" do
      before { DefraRubyMocks.configuration.enable = false }

      let(:company_number) { "SC247974" }

      it "cannot load the page" do
        expect { get "#{path}/#{company_number}" }.to raise_error(ActionController::RoutingError)
      end
    end

  end
end
