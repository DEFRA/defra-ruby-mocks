# frozen_string_literal: true

module DefraRuby
  module Mocks
    class NotFoundError < StandardError
    end

    class CompaniesHouseService < BaseService

      NOT_FOUND = "99999999"

      def run(company_number)
        raise NotFoundError if company_number == NOT_FOUND

        "active"
      end

    end
  end
end
