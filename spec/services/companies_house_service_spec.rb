# frozen_string_literal: true

require "rails_helper"

module DefraRubyMocks
  RSpec.describe CompaniesHouseService do
    describe ".run" do
      context "when the company number is 99999999 for not found" do
        let(:company_number) { "99999999" }

        it "raises a NotFoundError" do
          expect { described_class.run(company_number) }.to raise_error(NotFoundError)
        end
      end

      context "when the company number is from the 'specials' list" do
        specials = CompaniesHouseService.special_company_numbers

        specials.each do |company_number, status|
          context "and the number is #{company_number}" do
            it "returns a status of '#{status}'" do
              expect(described_class.run(company_number)).to eq(status)
            end
          end
        end
      end

      context "when the company number is not from the 'specials' list" do
        context "and it is valid" do
          let(:company_number) { "SC247974" }

          it "returns a status of 'active'" do
            expect(described_class.run(company_number)).to eq("active")
          end
        end

        context "and it is not valid" do
          let(:company_number) { "foo" }

          it "raises a NotFoundError" do
            expect { described_class.run(company_number) }.to raise_error(NotFoundError)
          end
        end
      end
    end
  end
end
