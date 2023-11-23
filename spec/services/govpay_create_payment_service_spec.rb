# frozen_string_literal: true

require "rails_helper"

module DefraRubyMocks

  RSpec.describe GovpayCreatePaymentService do

    before(:each) do
      Helpers::Configuration.prep_for_tests
      DefraRubyMocks.configure do |config|
        config.govpay_domain = "http://localhost:3000/defra_ruby_mocks"
      end
    end

    let(:amount) { Faker::Number.number(digits: 4) }
    let(:description) { Faker::Lorem.sentence }
    let(:return_url) { File.join(DefraRubyMocks.configuration.govpay_domain, "/payments/secure/next-url-uuid-abc123") }

    describe ".run" do

      subject { described_class.run(amount: amount, description: description, return_url: return_url).deep_symbolize_keys }

      context "for a valid payment request" do

        it "returns a payment response with the order amount" do
          expect(subject[:amount]).to eq(amount)
        end

        it "returns a payment response with the description" do
          expect(subject[:description]).to eq(description)
        end

        it "returns a payment response with the return_url" do
          expect(subject[:_links][:next_url][:href]).to eq(return_url)
        end

        it "returns the expected status" do
          expect(subject[:state][:status]).to eq("created")
        end
      end
    end
  end
end
