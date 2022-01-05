# frozen_string_literal: true

require "rails_helper"

module DefraRubyMocks
  RSpec.describe "Company", type: :request do
    after(:all) { Helpers::Configuration.reset_for_tests }

    let(:path) { "/defra_ruby_mocks/company" }

    context "when mocks are enabled" do
      before(:each) { Helpers::Configuration.prep_for_tests }

      context "when the company number is 99999999 for not found" do
        let(:company_number) { "99999999" }

        it "returns a JSON response with a code of 404" do
          get "#{path}/#{company_number}"
          content = JSON.parse(response.body)

          expect(response.media_type).to eq("application/json")
          expect(response.code).to eq("404")
          expect(content).to include("errors")
        end
      end

      context "when the company number is from the 'specials' list" do
        let(:company_number) { "05868270" }

        it "returns a JSON response with a 200 code and a status that isn't 'active'" do
          get "#{path}/#{company_number}"
          company_status = JSON.parse(response.body)["company_status"]

          expect(response.media_type).to eq("application/json")
          expect(response.code).to eq("200")
          expect(company_status).not_to eq("active")
        end
      end

      context "when the company number is not from the 'specials' list" do
        context "and it is valid" do
          let(:company_number) { "SC247974" }

          it "returns a JSON response with a 200 code and a status of 'active'" do
            get "#{path}/#{company_number}"
            company_status = JSON.parse(response.body)["company_status"]
            company_type = JSON.parse(response.body)["type"]

            expect(response.media_type).to eq("application/json")
            expect(response.code).to eq("200")
            expect(company_status).to eq("active")
            expect(company_type).to eq("ltd")
          end
        end

        context "and it is not valid" do
          let(:company_number) { "foo" }

          it "returns a JSON response with a 404 code" do
            get "#{path}/#{company_number}"
            content = JSON.parse(response.body)

            expect(response.media_type).to eq("application/json")
            expect(response.code).to eq("404")
            expect(content).to include("errors")
          end
        end
      end
    end

    context "when mocks are disabled" do
      before(:all) { DefraRubyMocks.configuration.enable = false }

      let(:company_number) { "SC247974" }

      it "cannot load the page" do
        expect { get "#{path}/#{company_number}" }.to raise_error(ActionController::RoutingError)
      end
    end

  end
end
