# frozen_string_literal: true

require "rails_helper"

module DefraRubyMocks
  RSpec.describe CompaniesHouseService do
    describe ".run" do
      subject(:run_service) { described_class.run(company_number) }

      context "when the company number is 99999999 for not found" do
        let(:company_number) { "99999999" }

        it "raises a NotFoundError" do
          expect { run_service }.to raise_error(NotFoundError)
        end
      end

      context "when the company number is from the 'specials' list" do
        specials = described_class.special_company_numbers

        specials.each do |company_number, status|
          context "when the number is #{company_number}" do
            let(:company_number) { company_number }

            it "returns a company_status of '#{status}'" do
              expect(run_service.company_status).to eq(status)
            end

            it "returns a company_type of 'ltd'" do
              expect(run_service.company_type).to eq("ltd")
            end
          end
        end
      end

      context "when the company is an LLP" do
        described_class.llp_company_numbers.each do |company_number|
          let(:company_number) { company_number }

          it "returns a company_status of 'active'" do
            expect(run_service.company_status).to eq("active")
          end

          it "returns a company_type of 'llp'" do
            expect(run_service.company_type).to eq("llp")
          end
        end
      end

      context "when the company number is not from the 'specials' list" do
        context "when it is valid" do
          let(:company_number) { "SC247974" }

          it "returns a company_status of 'active'" do
            expect(run_service.company_status).to eq("active")
          end
        end

        context "when it is not valid" do
          let(:company_number) { "foo" }

          it "raises a NotFoundError" do
            expect { run_service }.to raise_error(NotFoundError)
          end
        end
      end
    end
  end
end
