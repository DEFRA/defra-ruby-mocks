# frozen_string_literal: true

require "rails_helper"

module DefraRuby
  module Mocks
    RSpec.describe "Company", type: :request do
      let(:path) { "/defra_ruby/mocks/company" }

      context "when the company number is not 99999999" do
        let(:company_number) { "SC247974" }

        it "responds with a content type of json" do
          get "#{path}/#{company_number}"
          expect(response.content_type).to eq("application/json")
        end

        it "the response contains a status of 'active'" do
          get "#{path}/#{company_number}"
          # binding.pry
          status = JSON.parse(response.body)["company_status"]

          expect(status).to eq("active")
        end

        it "responds to the GET request with a 200 status code" do
          get "#{path}/#{company_number}"
          expect(response.code).to eq("200")
        end
      end

      context "when the company number is 99999999" do
        let(:company_number) { "99999999" }

        it "responds with a content type of json" do
          get "#{path}/#{company_number}"
          expect(response.content_type).to eq("application/json")
        end

        it "responds to the GET request with a 404 status code" do
          get "#{path}/#{company_number}"
          expect(response.code).to eq("404")
        end
      end
    end
  end
end
