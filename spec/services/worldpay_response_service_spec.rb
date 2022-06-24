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

      allow(WasteCarriersResourceService).to receive(:run) { resource }
    end

    let(:resource) { double(:resource, order: order, company_name: company_name&.downcase) }

    let(:admin_code) { "admincode1" }
    let(:merchant_code) { "merchantcode1" }
    let(:mac_secret) { "mac1" }
    let(:reference) { "12345" }
    let(:order_code) { "54321" }
    let(:order_key) { "#{admin_code}^#{merchant_code}^#{order_code}" }
    let(:order_value) { 105_00 }
    let(:payment_status) { :AUTHORISED }
    let(:company_name) { "Pay for the thing" }

    let(:order) { double(:order, order_code: order_code, total_amount: order_value) }

    let(:mac) { Digest::MD5.hexdigest(mac_data.join).to_s }

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

    let(:args) do
      {
        success_url: success_url,
        failure_url: failure_url,
        pending_url: pending_url,
        cancel_url: cancel_url,
        error_url: error_url
      }
    end

    describe ".run" do
      context "when the request comes from the waste-carriers-front-office" do
        let(:success_url) { "http://example.com/fo/#{reference}/worldpay/success" }
        let(:failure_url) { "http://example.com/fo/#{reference}/worldpay/failure" }
        let(:pending_url) { "http://example.com/fo/#{reference}/worldpay/pending" }
        let(:cancel_url) { "http://example.com/fo/#{reference}/worldpay/cancel" }
        let(:error_url) { "http://example.com/fo/#{reference}/worldpay/error" }

        context "and is valid" do
          let(:relation) { double(:relation, first: registration) }
          let(:mac_data) { [order_key, order_value, "GBP", payment_status, mac_secret] }

          it "can extract the reference from the `success_url`" do
            expect(described_class.run(args).reference).to eq(reference)
          end

          it "can generate a valid order key" do
            expect(described_class.run(args).order_key).to eq(order_key)
          end

          context "and is for a successful payment" do
            it "can generate a valid mac" do
              expect(described_class.run(args).mac).to eq(mac)
            end

            it "returns a url in the expected format" do
              expected_response_url = "#{success_url}?#{query_string}"

              expect(described_class.run(args).url).to eq(expected_response_url)
            end

            context "and the company name is blank" do
              let(:company_name) { nil }

              it "can extract the reference from the `success_url`" do
                expect(described_class.run(args).reference).to eq(reference)
              end
            end
          end

          context "and is for a rejected payment" do
            let(:payment_status) { :REFUSED }
            let(:company_name) { "Reject for the thing" }

            it "can generate a valid mac" do
              expect(described_class.run(args).mac).to eq(mac)
            end

            it "returns a url in the expected format" do
              expected_response_url = "#{failure_url}?#{query_string}"

              expect(described_class.run(args).url).to eq(expected_response_url)
            end
          end

          context "and is for a stuck payment" do
            let(:payment_status) { :STUCK }
            let(:company_name) { "Give me a stuck thing" }

            it "can generate a valid mac" do
              expect(described_class.run(args).mac).to eq(mac)
            end

            it "returns a status of :STUCK" do
              expect(described_class.run(args).status).to eq(:STUCK)
            end
          end

          context "and is for a pending payment" do
            let(:payment_status) { :SENT_FOR_AUTHORISATION }
            let(:company_name) { "Pending for the thing" }

            it "can generate a valid mac" do
              expect(described_class.run(args).mac).to eq(mac)
            end

            it "returns a url in the expected format" do
              expected_response_url = "#{pending_url}?#{query_string}"

              expect(described_class.run(args).url).to eq(expected_response_url)
            end
          end

          context "and is for a cancelled payment" do
            let(:payment_status) { :CANCELLED }
            let(:company_name) { "Cancel the thing" }
            let(:mac_data) { [order_key, order_value, "GBP", mac_secret] }

            it "can generate a valid mac" do
              expect(described_class.run(args).mac).to eq(mac)
            end

            it "returns a url in the expected format" do
              expected_response_url = "#{cancel_url}?#{query_string}"

              expect(described_class.run(args).url).to eq(expected_response_url)
            end
          end

          context "and is for an errored payment" do
            let(:payment_status) { :ERROR }
            let(:company_name) { "Error the thing" }

            it "can generate a valid mac" do
              expect(described_class.run(args).mac).to eq(mac)
            end

            it "returns a url in the expected format" do
              expected_response_url = "#{error_url}?#{query_string}"

              expect(described_class.run(args).url).to eq(expected_response_url)
            end
          end
        end
      end

      context "when the request comes from the waste-carriers-frontend" do
        let(:success_url) { "http://example.com/your-registration/#{reference}/worldpay/success/54321/NEWREG?locale=en" }
        let(:failure_url) { "http://example.com/your-registration/#{reference}/worldpay/failure/54321/NEWREG?locale=en" }
        let(:pending_url) { "http://example.com/your-registration/#{reference}/worldpay/pending/54321/NEWREG?locale=en" }
        let(:cancel_url) { "http://example.com/your-registration/#{reference}/worldpay/cancel/54321/NEWREG?locale=en" }
        let(:error_url) { "http://example.com/your-registration/#{reference}/worldpay/error/54321/NEWREG?locale=en" }

        context "and is valid" do
          let(:relation) { double(:relation, first: registration) }
          let(:mac_data) { [order_key, order_value, "GBP", payment_status, mac_secret] }

          it "can extract the reference from the `success_url`" do
            expect(described_class.run(args).reference).to eq(reference)
          end

          it "can generate a valid order key" do
            expect(described_class.run(args).order_key).to eq(order_key)
          end

          context "and is for a successful payment" do
            it "can generate a valid mac" do
              expect(described_class.run(args).mac).to eq(mac)
            end

            it "returns a url in the expected format" do
              expected_response_url = "#{success_url}&#{query_string}"

              expect(described_class.run(args).url).to eq(expected_response_url)
            end
          end

          context "and is for a rejected payment" do
            let(:payment_status) { :REFUSED }
            let(:company_name) { "Reject for the thing" }

            it "can generate a valid mac" do
              expect(described_class.run(args).mac).to eq(mac)
            end

            it "returns a url in the expected format" do
              expected_response_url = "#{failure_url}&#{query_string}"

              expect(described_class.run(args).url).to eq(expected_response_url)
            end
          end

          context "and is for a stuck payment" do
            let(:payment_status) { :STUCK }
            let(:company_name) { "Give me a stuck thing" }

            it "can generate a valid mac" do
              expect(described_class.run(args).mac).to eq(mac)
            end

            it "returns a status of :STUCK" do
              expect(described_class.run(args).status).to eq(:STUCK)
            end
          end

          context "and is for a pending payment" do
            let(:payment_status) { :SENT_FOR_AUTHORISATION }
            let(:company_name) { "Pending for the thing" }

            it "can generate a valid mac" do
              expect(described_class.run(args).mac).to eq(mac)
            end

            it "returns a url in the expected format" do
              expected_response_url = "#{pending_url}&#{query_string}"

              expect(described_class.run(args).url).to eq(expected_response_url)
            end
          end

          context "and is for a cancelled payment" do
            let(:payment_status) { :CANCELLED }
            let(:company_name) { "Cancel the thing" }
            let(:mac_data) { [order_key, order_value, "GBP", mac_secret] }

            it "can generate a valid mac" do
              expect(described_class.run(args).mac).to eq(mac)
            end

            it "returns a url in the expected format" do
              expected_response_url = "#{cancel_url}&#{query_string}"

              expect(described_class.run(args).url).to eq(expected_response_url)
            end
          end

          context "and is for an errored payment" do
            let(:payment_status) { :ERROR }
            let(:company_name) { "Error the thing" }

            it "can generate a valid mac" do
              expect(described_class.run(args).mac).to eq(mac)
            end

            it "returns a url in the expected format" do
              expected_response_url = "#{error_url}&#{query_string}"

              expect(described_class.run(args).url).to eq(expected_response_url)
            end
          end
        end
      end
    end
  end
end
