# frozen_string_literal: true

require "rails_helper"

module DefraRuby
  module Mocks
    RSpec.describe "Test", type: :request do
      it "renders the appropriate template" do
        get "/defra_ruby/mocks/test"
        expect(response).to render_template("defra_ruby/mocks/test/show")
      end

      it "responds to the GET request with a 200 status code" do
        get "/defra_ruby/mocks/test"
        expect(response.code).to eq("200")
      end
    end
  end
end
