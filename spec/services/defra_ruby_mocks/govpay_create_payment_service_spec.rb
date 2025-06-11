# frozen_string_literal: true

require "rails_helper"

module DefraRubyMocks

  RSpec.describe GovpayCreatePaymentService do

    before do
      Helpers::Configuration.prep_for_tests
      DefraRubyMocks.configure do |config|
        # The back- and front-office mocks root URLs, not externally accessible in the hosted environments
        config.govpay_mocks_internal_root_url = "http://internal.mocks.host:1111/defra_ruby_mocks/govpay/v1"
        config.govpay_mocks_internal_root_url_other = "http://internal.mocks.host:8888/defra_ruby_mocks/govpay/v1"

        # The back- and front-office externally-accessible domains
        config.govpay_mocks_external_root_url = "http://external.back-office.host.cloud/defra_ruby_mocks/govpay/v1"
        config.govpay_mocks_external_root_url_other = "http://external.front-office.host.cloud/defra_ruby_mocks/govpay/v1"
      end
    end

    let(:description) { Faker::Lorem.sentence }

    describe ".run" do
      let(:amount) { Faker::Number.number(digits: 4) }

      subject(:run_service) do
        described_class.run(amount: amount, description: description).deep_symbolize_keys
      end

      context "with a valid payment request" do

        it "returns a payment response with the order amount" do
          expect(run_service[:amount]).to eq(amount)
        end

        it "returns a payment response with the description" do
          expect(run_service[:description]).to eq(description)
        end

        it "returns the expected status" do
          expect(run_service[:state][:status]).to eq("created")
        end
      end

      describe "return_url" do
        let(:govpay_mocks_external_root_url) { DefraRubyMocks.configuration.govpay_mocks_external_root_url }
        let(:path) { "/payments/secure/next-url-uuid-abc123" }

        it { expect(run_service[:return_url]).to eq "#{DefraRubyMocks.configuration.govpay_mocks_internal_root_url}#{path}" }
      end

      describe "next_url" do
        let(:path) { "/payments/secure/next-url-uuid-abc123" }

        subject(:next_url) { run_service[:_links][:next_url][:href] }

        context "when the host is the back-office" do
          before do
            DefraRubyMocks.configure do |config|
              # External URLs:
              config.govpay_mocks_external_root_url = "http://external.back-office.host.cloud/defra_ruby_mocks/govpay/v1"
              config.govpay_mocks_external_root_url_other = "http://external.front-office.host.cloud/defra_ruby_mocks/govpay/v1"
            end
          end

          # next_url should be on the FO
          it { expect(next_url).to eq "#{DefraRubyMocks.configuration.govpay_mocks_external_root_url_other}#{path}" }
        end

        context "when the host is the front-office" do
          before do
            DefraRubyMocks.configure do |config|
              # External URLs:
              config.govpay_mocks_external_root_url = "http://external.front-office.host.cloud/defra_ruby_mocks/govpay/v1"
              config.govpay_mocks_external_root_url_other = "http://external.back-office.host.cloud/defra_ruby_mocks/govpay/v1"
            end
          end

          # next_url should be on the BO
          it { expect(next_url).to eq "#{DefraRubyMocks.configuration.govpay_mocks_external_root_url_other}#{path}" }
        end
      end
    end
  end
end
