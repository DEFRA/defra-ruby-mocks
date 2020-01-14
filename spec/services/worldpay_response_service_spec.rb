# frozen_string_literal: true

require "rails_helper"

module DefraRubyMocks
  RSpec.describe WorldpayResponseService do
    describe ".run" do

      context "when the request comes from the waste-carriers-front-office" do
        let(:reference) { "12345" }
        let(:success_url) { "http://example.com/fo/#{reference}/worldpay/success" }

        it "can extract the reference from the `success_url`" do
          allow(::WasteCarriersEngine::TransientRegistration).to receive(:where)

          # Because we have not setup all the required mocks for this test
          # we expect this exception to happen. But really we're just
          # swallowing the error here to allow us to test the next
          # assertion
          expect { described_class.run(success_url) }.to raise_error(NoMethodError)

          expect(::WasteCarriersEngine::TransientRegistration).to have_received(:where).with(token: reference)
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

        let(:reference) { "98765" }
        let(:success_url) { "http://example.com/your-registration/#{reference}/worldpay/success/54321/NEWREG" }

        it "can extract the reference from the `success_url`" do
          allow(::WasteCarriersEngine::Registration).to receive(:where)

          # Because we have not setup all the required mocks for this test
          # we expect this exception to happen. But really we're just
          # swallowing the error here to allow us to test the next
          # assertion
          expect { described_class.run(success_url) }.to raise_error(NoMethodError)

          expect(::WasteCarriersEngine::Registration).to have_received(:where).with(reg_uuid: reference)
        end
      end
    end
  end
end
