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

    let(:http_client) { class_double(RestClient::Request).as_stubbed_const }

    before { allow(http_client).to receive(:execute).with(instance_of(Hash)) }

    it { expect { run_job }.not_to raise_error }

    it "sends the webhook" do
      run_job

      expect(http_client).to have_received(:execute)
        .with(hash_including(payload: /"payment_id":"#{govpay_id}"/))
    end
  end
end
