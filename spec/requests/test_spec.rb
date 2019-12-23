# frozen_string_literal: true

require "rails_helper"

module DefraRubyMocks
  RSpec.describe "Test", type: :request do
    it "renders the appropriate template" do
      get "/defra_ruby_mocks/test"
      expect(response).to render_template("defra_ruby_mocks/test/show")
    end

    it "responds to the GET request with a 200 status code" do
      get "/defra_ruby_mocks/test"
      expect(response.code).to eq("200")
    end
  end
end
