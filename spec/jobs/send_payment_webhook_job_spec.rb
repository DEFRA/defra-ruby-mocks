# frozen_string_literal: true

require "rails_helper"
require "restclient"

RSpec.describe SendPaymentWebhookJob do

  describe "#perform" do
    subject(:run_job) { described_class.new.perform(govpay_id:, status:, callback_url:, signing_secret:) }

    let(:govpay_id) { SecureRandom.hex }
    let(:signing_secret) { SecureRandom.hex(16) }
    let(:status) { "success" }
    let(:callback_url) { Faker::Internet.url }

    let(:http_client) { instance_double(RestClient::Request) }

    before do
      allow(RestClient::Request).to receive(:new).and_return(http_client)
      allow(http_client).to receive(:execute)
    end

    it { expect { run_job }.not_to raise_error }

    it "sends the webhook" do
      run_job

      expect(http_client).to have_received(:execute)
    end
  end
end
