# frozen_string_literal: true

require "rails_helper"

module DefraRubyMocks
  RSpec.describe WorldpayResponseService do
    before(:each) do
      Helpers::Configuration.prep_for_tests
      DefraRubyMocks.configure do |config|
        config.worldpay_admin_code = admin_code
        config.worldpay_merchant_code = merchant_code
        config.worldpay_mac_secret = "macsecret1"
      end
    end

    let(:admin_code) { "admincode1" }
    let(:merchant_code) { "merchantcode1" }
    let(:reference) { "12345" }
    let(:order_code) { "54321" }
    let(:order_key) { "#{admin_code}^#{merchant_code}^#{order_code}" }

    describe ".run" do
      before do
        allow(relation).to receive(:first) { registration }
        allow(registration).to receive(:finance_details) { finance_details }
        allow(finance_details).to receive(:orders) { orders }
        allow(orders).to receive(:order_by) { orders }
        allow(orders).to receive(:first) { order }
      end
      let(:relation) { double(:relation) }
      let(:registration) { double(:registration) }
      let(:finance_details) { double(:finance_details) }
      let(:orders) { double(:orders) }
      let(:order) { double(:order, order_code: order_code, total_amount: 105_00) }

      context "when the request comes from the waste-carriers-front-office" do
        before do
          allow(::WasteCarriersEngine::TransientRegistration).to receive(:where) { relation }
        end

        let(:success_url) { "http://example.com/fo/#{reference}/worldpay/success" }

        it "can extract the reference from the `success_url`" do
          described_class.run(success_url)

          expect(::WasteCarriersEngine::TransientRegistration).to have_received(:where).with(token: reference)
        end

        it "can generate a valid order key" do
          params = parse_for_params(described_class.run(success_url))

          expect(params["orderKey"]).to eq(order_key)
        end
      end

      context "when the request comes from the waste-carriers-frontend" do
        before do
          # The service will search transient registrations for a match first
          # before then searching for the registration. Hence we need to stub
          # `locate_transient_registration()` to allow the service to then
          # call `locate_registration()`
          allow_any_instance_of(described_class).to receive(:locate_transient_registration).and_return(nil)

          allow(::WasteCarriersEngine::Registration).to receive(:where) { relation }
        end

        let(:success_url) { "http://example.com/your-registration/#{reference}/worldpay/success/54321/NEWREG?locale=en" }

        it "can extract the reference from the `success_url`" do
          described_class.run(success_url)

          expect(::WasteCarriersEngine::Registration).to have_received(:where).with(reg_uuid: reference)
        end

        it "can generate a valid order key" do
          params = parse_for_params(described_class.run(success_url))

          expect(params["orderKey"]).to eq(order_key)
        end
      end
    end
  end
end
