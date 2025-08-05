# frozen_string_literal: true

require "rails_helper"
require "restclient"

RSpec.describe SendPaymentWebhookJob do

  describe "#perform" do
    subject(:run_job) do
      described_class.new.perform(
        govpay_payment_id:,
        govpay_payment_status:,
        callback_url:,
        signing_secret: SecureRandom.hex(16)
      )
    end

    let(:govpay_payment_id) { SecureRandom.hex }
    let(:govpay_payment_status) { "success" }
    let(:callback_url) { Faker::Internet.url }

    before { allow(RestClient::Request).to receive(:execute) }

    it { expect { run_job }.not_to raise_error }

    # rubocop:disable RSpec/ExampleLength -- the test logic is clearer in a single spec than spread across multiple
    it "sends the webhook" do
      run_job

      expect(RestClient::Request).to have_received(:execute).with(
        hash_including(
          method: :post,
          url: callback_url,
          headers: hash_including("Pay-Signature": a_kind_of(String)),
          payload: satisfy { |json| JSON.parse(json)["resource"]["payment_id"] == govpay_payment_id }
        )
      )
    end
    # rubocop:enable RSpec/ExampleLength
  end
end
