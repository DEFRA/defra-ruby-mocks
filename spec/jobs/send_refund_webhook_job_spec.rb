# frozen_string_literal: true

require "rails_helper"
require "restclient"

RSpec.describe SendRefundWebhookJob do

  describe "#perform" do
    subject(:run_job) do
      described_class.new.perform(
        govpay_payment_id: SecureRandom.hex,
        govpay_refund_id:,
        govpay_refund_status: "success",
        callback_url:,
        signing_secret: SecureRandom.hex(16)
      )
    end

    let(:govpay_refund_id) { SecureRandom.hex }
    let(:callback_url) { Faker::Internet.url }

    before { allow(RestClient::Request).to receive(:execute).with(instance_of(Hash)) }

    it { expect { run_job }.not_to raise_error }

    # rubocop:disable RSpec/ExampleLength -- the test logic is clearer in a single spec than spread across multiple
    it "sends the webhook" do
      run_job

      expect(RestClient::Request).to have_received(:execute).with(
        hash_including(
          method: :post,
          url: callback_url,
          headers: hash_including("Pay-Signature": a_kind_of(String)),
          payload: satisfy { |json| JSON.parse(json)["refund_id"] == govpay_refund_id }
        )
      )
    end
    # rubocop:enable RSpec/ExampleLength
  end
end
