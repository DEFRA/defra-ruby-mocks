# frozen_string_literal: true

require "rails_helper"

module DefraRubyMocks

  RSpec.describe GovpayGetPaymentService do
    before { Helpers::Configuration.prep_for_tests }

    let(:order_value) { Faker::Number.number(digits: 4) }
    let(:payment_id) { SecureRandom.hex(26) }

    describe ".run" do

      subject { described_class.run(payment_id: payment_id, amount: order_value).deep_symbolize_keys }

      context "when the payment is successful" do

        it "returns a payment with the order amount" do
          expect(subject[:amount]).to eq(order_value)
        end

        it "returns the expected status" do
          expect(subject[:state][:status]).to eq("success")
        end
      end

      context "when the payment is rejected" do
        let(:payment_id) { "#{SecureRandom.hex(26)}_rejected" }

        it "returns the expected status" do
          expect(subject[:state][:status]).to eq("failed")
        end
      end

      context "when the payment is pending" do
        let(:payment_id) { "#{SecureRandom.hex(26)}_pending" }

        it "returns the expected status" do
          expect(subject[:state][:status]).to eq("created")
        end
      end

      context "when the payment is cancelled" do
        let(:payment_id) { "#{SecureRandom.hex(26)}_cancel" }

        it "returns the expected status" do
          # Govpay returns a "failed" status with a special error code for cancelled payments
          expect(subject[:state][:status]).to eq("failed")
          expect(subject[:state][:code]).to eq("P0030")
        end
      end

      context "when the payment is errored" do
        let(:payment_id) { "#{SecureRandom.hex(26)}_error" }

        it "returns the expected error code" do
          expect(subject[:code]).to eq("P0200")
        end
      end
    end
  end
end
