# frozen_string_literal: true

require "rails_helper"

module DefraRubyMocks

  RSpec.describe GovpayRefundDetailsService do
    let(:payment_id) { SecureRandom.hex(26) }
    let(:refund_id) { SecureRandom.hex(22) }

    before { Helpers::Configuration.prep_for_tests }

    # Note that the service currently supports only success responses.
    describe ".run" do
      let(:create_request_time) { Time.zone.now }
      let(:submitted_success_lag) { "10" }

      subject { described_class.run(payment_id: payment_id, refund_id: refund_id).deep_symbolize_keys }

      # the service shoud return "submitted" for up to GOVPAY_REFUND_SUBMITTED_SUCCESS_LAG seconds, "success" thereafter
      before do
        Timecop.freeze(create_request_time)
        allow(ENV).to receive(:fetch).with("GOVPAY_REFUND_SUBMITTED_SUCCESS_LAG", any_args).and_return(submitted_success_lag)
        FileUtils.rm_rf("#{Dir.tmpdir}/govpay_request_refund_service_last_run_time")
      end

      context "when no refund timestamp file exists" do
        it { expect(subject[:status]).to eq "success" }
      end

      context "when a refund has been requested" do
        before do
          GovpayRequestRefundService.run(payment_id: payment_id, amount: 100, refund_amount_available: 100).deep_symbolize_keys
        end

        context "when less than 10 seconds has elapsed since the last create request" do
          before { Timecop.freeze(create_request_time + (submitted_success_lag.to_i - 8).seconds) }

          it { expect(subject[:status]).to eq "submitted" }
        end

        context "when 10 seconds has elapsed since the last create request" do
          before { Timecop.freeze(create_request_time + (submitted_success_lag.to_i + 8).seconds) }

          it { expect(subject[:status]).to eq "success" }
        end

        context "when GOVPAY_REFUND_SUBMITTED_SUCCESS_LAG is not set" do
          let(:submitted_success_lag) { nil }

          before { Timecop.freeze(create_request_time + 1.hour) }

          it { expect(subject[:status]).to eq "success" }
        end
      end
    end
  end
end
