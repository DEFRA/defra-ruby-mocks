# frozen_string_literal: true

require "rails_helper"

module DefraRuby
  RSpec.describe "Company", type: :request do
    before(:all) do
      DefraRubyMocks.configure do |config|
        config.delay = 100
      end
    end
    after(:all) { DefraRubyMocks.reset_configuration }

    let(:path) { "/defra_ruby_mocks/company" }

    context "when the company number is from the 'specials' list" do

      context "and is 99999999 for not found" do
        let(:company_number) { "99999999" }

        it "returns a JSON response with a code of 404" do
          get "#{path}/#{company_number}"
          content = JSON.parse(response.body)

          expect(response.content_type).to eq("application/json")
          expect(response.code).to eq("404")
          expect(content).to include("errors")
        end
      end

      specials = {
        "05868270": "dissolved",
        "04270505": "administration",
        "88888888": "liquidation",
        "77777777": "receivership",
        "66666666": "converted-closed",
        "55555555": "voluntary-arrangement",
        "44444444": "insolvency-proceedings",
        "33333333": "open",
        "22222222": "closed"
      }
      specials.each do |company_number, status|
        context "and the number is #{company_number}" do
          it "returns a JSON response with a 200 code and a status of '#{status}'" do
            get "#{path}/#{company_number}"
            company_status = JSON.parse(response.body)["company_status"]

            expect(response.content_type).to eq("application/json")
            expect(response.code).to eq("200")
            expect(company_status).to eq(status)
          end
        end
      end
    end

    context "when the company number is not from the 'specials' list" do
      context "and it is valid" do
        let(:company_number) { "SC247974" }

        it "returns a JSON response with a 200 code and a status of 'active'" do
          get "#{path}/#{company_number}"
          company_status = JSON.parse(response.body)["company_status"]

          expect(response.content_type).to eq("application/json")
          expect(response.code).to eq("200")
          expect(company_status).to eq("active")
        end
      end

      context "and it is not valid" do
        let(:company_number) { "foo" }

        it "returns a JSON response with a 404 code" do
          get "#{path}/#{company_number}"
          content = JSON.parse(response.body)

          expect(response.content_type).to eq("application/json")
          expect(response.code).to eq("404")
          expect(content).to include("errors")
        end
      end
    end
  end
end
