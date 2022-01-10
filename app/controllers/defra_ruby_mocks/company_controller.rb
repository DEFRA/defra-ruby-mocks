# frozen_string_literal: true

module DefraRubyMocks
  class CompanyController < ::DefraRubyMocks::ApplicationController

    before_action :set_default_response_format

    def show
      service = CompaniesHouseService.run(params[:id])

      @company_status = service.company_status
      @company_type = service.company_type

      respond_to :json
    rescue NotFoundError
      render "not_found", status: 404
    end

    def officers
      respond_to :json
    end

    private

    def set_default_response_format
      request.format = :json
    end

  end
end
