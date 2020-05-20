# frozen_string_literal: true

require "rails_helper"

module DefraRubyMocks
  RSpec.describe WorldpayResponseService do
    before(:each) do
      Helpers::Configuration.prep_for_tests
      DefraRubyMocks.configure do |config|
        config.worldpay_admin_code = admin_code
        config.worldpay_merchant_code = merchant_code
        config.worldpay_mac_secret = mac_secret
      end

      allow(::WasteCarriersEngine::TransientRegistration).to receive(:where) { relation }
      allow(::WasteCarriersEngine::Registration).to receive(:where) { relation }
    end

    let(:admin_code) { "admincode1" }
    let(:merchant_code) { "merchantcode1" }
    let(:mac_secret) { "mac1" }
    let(:reference) { "12345" }
    let(:order_code) { "54321" }
    let(:order_key) { "#{admin_code}^#{merchant_code}^#{order_code}" }
    let(:order_value) { 105_00 }
    let(:payment_status) { "AUTHORISED" }
    let(:company_name) { "Pay for the thing" }

    let(:registration) { double(:registration, finance_details: finance_details, company_name: company_name) }
    let(:finance_details) { double(:finance_details, orders: orders) }
    let(:orders) { double(:orders, order_by: sorted_orders) }
    let(:sorted_orders) { double(:sorted_orders, first: order) }
    let(:order) { double(:order, order_code: order_code, total_amount: order_value) }

    let(:mac) do
      data = [
        order_key,
        order_value,
        "GBP",
        payment_status,
        mac_secret
      ]

      Digest::MD5.hexdigest(data.join).to_s
    end

    let(:query_string) do
      [
        "orderKey=#{order_key}",
        "paymentStatus=#{payment_status}",
        "paymentAmount=#{order_value}",
        "paymentCurrency=GBP",
        "mac=#{mac}",
        "source=WP"
      ].join("&")
    end

    let(:args) { { success_url: success_url, failure_url: failure_url } }

    describe ".run" do
      context "when the request comes from the waste-carriers-front-office" do
        let(:success_url) { "http://example.com/fo/#{reference}/worldpay/success" }
        let(:failure_url) { "http://example.com/fo/#{reference}/worldpay/failure" }

        context "and is valid" do
          let(:relation) { double(:relation, first: registration) }

          it "can extract the reference from the `success_url`" do
            described_class.run(args)

            expect(::WasteCarriersEngine::TransientRegistration).to have_received(:where).with(token: reference)
          end

          it "can generate a valid order key" do
            params = parse_for_params(described_class.run(args))

            expect(params["orderKey"]).to eq(order_key)
          end

          it "can generate a valid mac" do
            params = parse_for_params(described_class.run(args))

            expect(params["mac"]).to eq(mac)
          end

          context "and is for a successful payment" do
            it "returns a url in the expected format" do
              expected_response = "#{success_url}?#{query_string}"

              expect(described_class.run(args)).to eq(expected_response)
            end
          end

          context "and is for a rejected payment" do
            let(:payment_status) { "REFUSED" }
            let(:company_name) { "Reject for the thing" }

            it "returns a url in the expected format" do
              expected_response = "#{failure_url}?#{query_string}"

              expect(described_class.run(args)).to eq(expected_response)
            end
          end

          context "and is for a stuck payment" do
            let(:payment_status) { "REFUSED" }
            let(:company_name) { "Give me a stuck thing" }

            it "returns 'nil'" do
              expected_response = nil

              expect(described_class.run(args)).to eq(expected_response)
            end
          end
        end

        context "but the registration does not exist" do
          let(:relation) { double(:relation, first: nil) }

          it "causes an error" do
            expect { described_class.run(args) }.to raise_error MissingRegistrationError
          end
        end

        context "but the registration does not exist" do
          let(:relation) { double(:relation, first: nil) }

          it "causes an error" do
            expect { described_class.run(args) }.to raise_error MissingRegistrationError
          end
        end
      end

      context "when the request comes from the waste-carriers-frontend" do
        before do
          # The service will search transient registrations for a match first
          # before then searching for the registration. Hence we need to stub
          # `locate_transient_registration()` to allow the service to then
          # call `locate_registration()`
          allow_any_instance_of(described_class).to receive(:locate_transient_registration).and_return(nil)
        end

        let(:success_url) { "http://example.com/your-registration/#{reference}/worldpay/success/54321/NEWREG?locale=en" }
        let(:failure_url) { "http://example.com/your-registration/#{reference}/worldpay/failure/54321/NEWREG?locale=en" }

        context "and is valid" do
          let(:relation) { double(:relation, first: registration) }

          it "can extract the reference from the `success_url`" do
            described_class.run(args)

            expect(::WasteCarriersEngine::Registration).to have_received(:where).with(reg_uuid: reference)
          end

          it "can generate a valid order key" do
            params = parse_for_params(described_class.run(args))

            expect(params["orderKey"]).to eq(order_key)
          end

          it "can generate a valid mac" do
            params = parse_for_params(described_class.run(args))

            expect(params["mac"]).to eq(mac)
          end

          context "and is for a successful payment" do
            it "returns a url in the expected format" do
              expected_response = "#{success_url}&#{query_string}"

              expect(described_class.run(args)).to eq(expected_response)
            end
          end

          context "and is for a rejected payment" do
            let(:payment_status) { "REFUSED" }
            let(:company_name) { "Reject for the thing" }

            it "returns a url in the expected format" do
              expected_response = "#{failure_url}&#{query_string}"

              expect(described_class.run(args)).to eq(expected_response)
            end
          end
        end

        context "but the registration does not exist" do
          let(:relation) { double(:relation, first: nil) }

          it "causes an error" do
            expect { described_class.run(args) }.to raise_error MissingRegistrationError
          end
        end
      end
    end
  end
end
