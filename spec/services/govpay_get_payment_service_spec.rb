# frozen_string_literal: true

require "rails_helper"

module DefraRubyMocks

  RSpec.describe GovpayGetPaymentService do
    before { Helpers::Configuration.prep_for_tests }

    let(:order_value) { Faker::Number.number(digits: 4) }
    let(:payment_id) { SecureRandom.hex(26) }

    # Note that the service currently supports only success responses.
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
    end
  end
end
