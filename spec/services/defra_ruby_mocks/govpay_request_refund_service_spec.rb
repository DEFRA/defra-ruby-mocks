# frozen_string_literal: true

require "rails_helper"

module DefraRubyMocks

  RSpec.describe GovpayRequestRefundService do
    let(:payment_id) { SecureRandom.hex(26) }
    let(:amount) { 2000 }
    let(:refund_amount_available) { amount }
    let(:aws_bucket_service) { instance_double(AwsBucketService) }

    before do
      Helpers::Configuration.prep_for_tests
      allow(AwsBucketService).to receive(:write)
      allow(AwsBucketService).to receive(:read)
    end

    # Note that the service currently supports only "submitted" responses.
    describe ".run" do

      subject(:run_service) do
        described_class.run(payment_id: payment_id, amount: amount, refund_amount_available: refund_amount_available).deep_symbolize_keys
      end

      context "when the refund has been successfully submitted" do

        it "returns a response with the expected status" do
          expect(run_service[:status]).to eq("submitted")
        end

        it "returns a response with the expected amount" do
          expect(run_service[:amount]).to eq(amount)
        end
      end
    end
  end
end
