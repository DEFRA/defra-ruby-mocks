# frozen_string_literal: true

require "rails_helper"

module DefraRubyMocks
  RSpec.describe WorldpayResourceService do
    before(:each) do
      allow(::WasteCarriersEngine::TransientRegistration).to receive(:where) { transient_relation }
      allow(::WasteCarriersEngine::Registration).to receive(:where) { registration_relation }
    end

    let(:reference) { "12345" }
    let(:company_name) { "Pay for the thing" }

    let(:resource) { double(:resource, finance_details: finance_details, company_name: company_name) }
    let(:finance_details) { double(:finance_details, orders: orders) }
    let(:orders) { double(:orders, order_by: sorted_orders) }
    let(:sorted_orders) { double(:sorted_orders, first: order) }
    let(:order) { double(:order) }

    let(:args) { { reference: reference } }

    describe ".run" do

      context "when the resource is a TransientRegistration" do
        let(:transient_relation) { double(:relation, first: resource) }

        it "will only search transient registrations" do
          described_class.run(args)

          expect(::WasteCarriersEngine::TransientRegistration).to have_received(:where).with(token: reference)

          expect(::WasteCarriersEngine::Registration).not_to have_received(:where).with(reg_uuid: reference)
        end

        it "returns an object with the matching resource" do
          expect(described_class.run(args).resource).to eq(resource)
        end

        it "returns an object with the expected order" do
          expect(described_class.run(args).order).to eq(order)
        end

        it "returns an object with the expected company name" do
          expect(described_class.run(args).company_name).to eq(company_name.downcase)
        end

        context "when the company name is not populated" do
          let(:company_name) { nil }

          it "returns the object" do
            expect(described_class.run(args).resource).to eq(resource)
          end
        end
      end

      context "when the resource is a Registration" do
        let(:transient_relation) { double(:relation, first: nil) }
        let(:registration_relation) { double(:relation, first: resource) }

        it "will search transient registrations first, then registrations" do
          described_class.run(args)

          expect(::WasteCarriersEngine::TransientRegistration).to have_received(:where).with(token: reference)

          expect(::WasteCarriersEngine::Registration).to have_received(:where).with(reg_uuid: reference)
        end

        it "returns an object with the matching resource" do
          expect(described_class.run(args).resource).to eq(resource)
        end

        it "returns an object with the expected order" do
          expect(described_class.run(args).order).to eq(order)
        end

        it "returns an object with the expected company name" do
          expect(described_class.run(args).company_name).to eq(company_name.downcase)
        end
      end

      context "when the resource is a OrderCopyCardsRegistration" do
        before do
          # Because we do not copy the company name to
          # `OrderCopyCardsRegistration` instances when we create them in WCR
          # we need to locate the orignal registration they are based on. We
          # determine in the class if the 'resource' is an instance of one by
          # comparing the result of resource.class.to_s to
          # "WasteCarriersEngine::OrderCopyCardsRegistration". The problem is
          # when testing 'resource' is actually an instance of
          # `RSpec::Mocks::Double`! So we subvert the call to class on
          # RSpec::Mocks::Double to return "WasteCarriersEngine::OrderCopyCardsRegistration"
          # just in this spec. We can then test that the service does indeed
          # locate the original registration for a company name
          allow_any_instance_of(RSpec::Mocks::Double).to receive(:class)
            .and_return("WasteCarriersEngine::OrderCopyCardsRegistration")
        end

        let(:copy_card_resource) { double(:resource, finance_details: finance_details, reg_identifier: "CBDU123") }
        let(:transient_relation) { double(:relation, first: copy_card_resource) }
        let(:registration_relation) { double(:relation, first: resource) }

        it "locates the original registration to grab the company name" do
          expect(described_class.run(args).company_name).to eq(company_name.downcase)

          expect(::WasteCarriersEngine::Registration).to have_received(:where).with(reg_identifier: "CBDU123")
        end
      end

      context "when the resource does not exist" do
        let(:transient_relation) { double(:relation, first: nil) }
        let(:registration_relation) { double(:relation, first: nil) }

        it "causes an error" do
          expect { described_class.run(args) }.to raise_error MissingResourceError
        end
      end
    end
  end
end
