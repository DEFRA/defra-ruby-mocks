# frozen_string_literal: true

module DefraRuby
  module Mocks
    class CompanyController < ApplicationController

      before_action :set_default_response_format

      def show
        @status = CompaniesHouseService.run(params[:id])

        respond_to :json
      rescue NotFoundError
        render "not_found", status: 404
      end

      private

      def set_default_response_format
        request.format = :json
      end

    end
  end
end
