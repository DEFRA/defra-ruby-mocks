# frozen_string_literal: true

module DefraRubyMocks
  class NotFoundError < StandardError
  end

  class CompaniesHouseService < BaseService

    # Examples we need to validate are
    # 10997904, 09764739
    # SC534714, CE000958
    # IP00141R, IP27702R, SP02252R
    # https://assets.publishing.service.gov.uk/government/uploads/system/uploads/attachment_data/file/426891/uniformResourceIdentifiersCustomerGuide.pdf
    VALID_COMPANIES_HOUSE_REGISTRATION_NUMBER_REGEX = Regexp.new(
      /\A(\d{8,8}$)|([a-zA-Z]{2}\d{6}$)|([a-zA-Z]{2}\d{5}[a-zA-Z]{1}$)\z/i
    ).freeze

    NOT_FOUND = "99999999"

    def self.special_company_numbers
      {
        "05868270" => "dissolved",
        "04270505" => "administration",
        "88888888" => "liquidation",
        "77777777" => "receivership",
        "66666666" => "converted-closed",
        "55555555" => "voluntary-arrangement",
        "44444444" => "insolvency-proceedings",
        "33333333" => "open",
        "22222222" => "closed"
      }
    end

    def self.llp_company_numbers
      %w[XX999999 YY999999]
    end

    def run(company_number)
      raise NotFoundError unless valid_company_number?(company_number)
      raise NotFoundError if company_number == NOT_FOUND

      @company_status = specials[company_number] || "active"
      @company_type = llps.include?(company_number) ? "llp" : "ltd"

      self
    end

    attr_reader :company_status, :company_type

    private

    def valid_company_number?(company_number)
      company_number.match?(VALID_COMPANIES_HOUSE_REGISTRATION_NUMBER_REGEX)
    end

    def specials
      self.class.special_company_numbers
    end

    def llps
      self.class.llp_company_numbers
    end
  end
end
