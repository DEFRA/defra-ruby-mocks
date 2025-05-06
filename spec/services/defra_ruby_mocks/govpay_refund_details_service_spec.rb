# frozen_string_literal: true

require "rails_helper"

module DefraRubyMocks

  RSpec.describe GovpayRefundDetailsService do
    let(:payment_id) { SecureRandom.hex(26) }
    let(:refund_id) { SecureRandom.hex(22) }

    before { Helpers::Configuration.prep_for_tests }

    # Note that the service currently supports only success responses.
    describe ".run" do
      let(:submitted_success_lag) { "10" }
      let(:aws_bucket_service) { instance_double(AwsBucketService) }

      subject(:run_service) do
        described_class.run(payment_id: payment_id, refund_id: refund_id).deep_symbolize_keys
      end

      # the service shoud return "submitted" for up to GOVPAY_REFUND_SUBMITTED_SUCCESS_LAG seconds, "success" thereafter
      before do
        allow(ENV).to receive(:fetch)
        allow(ENV).to receive(:fetch).with("GOVPAY_REFUND_SUBMITTED_SUCCESS_LAG", any_args).and_return(submitted_success_lag)
        allow(AwsBucketService).to receive(:new).and_return(aws_bucket_service)
        allow(aws_bucket_service).to receive(:write)
        allow(aws_bucket_service).to receive(:read)
      end

      context "when no refund timestamp file exists" do
        it { expect(run_service[:status]).to eq "success" }
      end

      context "when a refund has been requested" do

        before do
          Timecop.freeze(last_request_time) do
            GovpayRequestRefundService.run(payment_id: payment_id, amount: 100, refund_amount_available: 100).deep_symbolize_keys
          end
          allow(aws_bucket_service).to receive(:read)
            .with(ENV.fetch("AWS_DEFRA_RUBY_MOCKS_BUCKET", nil), "govpay_request_refund_service_last_run_time")
            .and_return(last_request_time.to_s)
        end

        context "when less than 10 seconds has elapsed since the last create request" do
          let(:last_request_time) { Time.zone.now - 8.seconds }

          it { expect(run_service[:status]).to eq "submitted" }
        end

        context "when 10 seconds has elapsed since the last create request" do
          let(:last_request_time) { Time.zone.now - 11.seconds }

          it { expect(run_service[:status]).to eq "success" }
        end

        context "when GOVPAY_REFUND_SUBMITTED_SUCCESS_LAG is not set" do
          let(:last_request_time) { nil }
          let(:submitted_success_lag) { nil }

          it { expect(run_service[:status]).to eq "success" }
        end
      end
    end
  end
end
