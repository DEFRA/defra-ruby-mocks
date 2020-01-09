require "rails_helper"

module DefraRubyMocks
  RSpec.describe "Worldpay", type: :request do
    after(:all) { Helpers::Configuration.reset_for_tests }

    context "when mocks are enabled" do
      before(:each) do
        Helpers::Configuration.prep_for_tests
        DefraRubyMocks.configure do |config|
          config.worldpay_admin_code = "admincode1"
          config.worldpay_mac_secret = "macsecret1"
          config.worldpay_domain = "http://localhost:3000/defra_ruby_mocks"
        end
      end

      context "#payments_service" do
        let(:path) { "/defra_ruby_mocks/worldpay/payments-service" }

        context "and the request is valid" do
          let(:data) { File.read("spec/fixtures/worldpay_request_valid.xml") }

          it "returns an XML response with a 200 code" do
            get path, {}, "RAW_POST_DATA" => data

            expect(response.content_type).to eq("application/xml")
            expect(response.code).to eq("200")
          end
        end

        context "and the request is invalid" do
          let(:data) { File.read("spec/fixtures/worldpay_request_invalid.xml") }

          it "returns a response with a 500 code" do
            get path, {}, "RAW_POST_DATA" => data

            expect(response.code).to eq("500")
          end
        end
      end

      context "#dispatcher" do
        let(:registration_relation) { double(:registration_relation) }
        let(:transient_registration_relation) { double(:transient_registration_relation) }
        let(:registration) { double(:registration) }
        let(:transient_registration) { double(:transient_registration) }
        let(:finance_details) { double(:finance_details) }
        let(:orders) { double(:orders) }
        let(:order) { double(:order, order_code: "987654", total_amount: 105_00) }

        let(:path) { "/defra_ruby_mocks/worldpay/dispatcher?successURL=#{CGI.escape(success_url)}" }

        context "and the request is valid" do
          let(:response_params) { "orderKey=admincode1^^987654&paymentStatus=AUTHORISED&paymentAmount=10500&paymentCurrency=GBP&mac=0ba5271e1ed1b26f9bb428ef7fb536a4&source=WP" }

          context "and comes from the waste-carriers-front-office project" do
            let(:success_url) { "http://example.com/fo/12345/worldpay/success" }

            it "redirects the user with a 300 code" do

              expect(::WasteCarriersEngine::TransientRegistration).to receive(:where).and_return(transient_registration_relation)
              expect(transient_registration_relation).to receive(:first) { transient_registration }
              expect(transient_registration).to receive(:finance_details).and_return(finance_details)
              expect(finance_details).to receive(:orders).and_return(orders)
              expect(orders).to receive(:order_by).and_return(orders)
              expect(orders).to receive(:first).and_return(order)

              get path

              expect(response).to redirect_to("#{success_url}?#{response_params}")
              expect(response.code).to eq("302")
            end
          end

          context "and comes from the waste-carriers-frontend project" do
            let(:success_url) { "http://example.com/your-registration/12345/worldpay/success/54321/NEWREG" }

            it "redirects the user with a 300 code" do

              expect(::WasteCarriersEngine::TransientRegistration).to receive(:where).and_return(transient_registration_relation)
              expect(transient_registration_relation).to receive(:first) { transient_registration }
              expect(transient_registration).to receive(:finance_details).and_return(finance_details)
              expect(finance_details).to receive(:orders).and_return(orders)
              expect(orders).to receive(:order_by).and_return(orders)
              expect(orders).to receive(:first).and_return(order)

              get path

              expect(response).to redirect_to("#{success_url}&#{response_params}")
              expect(response.code).to eq("302")
            end
          end
        end

        context "and the request is invalid" do
          context "because the success url is not in a recognised format" do
            let(:success_url) { "http://example.com/forthewin" }

            it "returns a response with a 500 code" do
              get path

              expect(response.code).to eq("500")
            end
          end

          context "because the success url contains an ID for a unknown registration" do
            let(:success_url) { "http://example.com/fo/12345/worldpay/success" }

            it "returns a response with a 500 code" do
              expect(::WasteCarriersEngine::TransientRegistration).to receive(:where).and_return(transient_registration_relation)
              expect(transient_registration_relation).to receive(:first) { nil }

              expect(::WasteCarriersEngine::Registration).to receive(:where).and_return(registration_relation)
              expect(registration_relation).to receive(:first) { nil }

              get path

              expect(response.code).to eq("500")
            end
          end
        end
      end
    end

    context "when mocks are disabled" do
      before(:each) { DefraRubyMocks.configuration.enable = false }

      context "#payments_service" do
        let(:path) { "/defra_ruby_mocks/worldpay/payments-service" }

        it "cannot load the page" do
          expect { get path }.to raise_error(ActionController::RoutingError)
        end
      end

      context "#dispatcher" do
        let(:path) { "/defra_ruby_mocks/worldpay/dispatcher" }

        it "cannot load the page" do
          expect { get path }.to raise_error(ActionController::RoutingError)
        end
      end
    end
  end
end
