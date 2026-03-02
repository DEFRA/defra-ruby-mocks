# frozen_string_literal: true

module DefraRubyMocks
  class OsPlacesController < ::DefraRubyMocks::ApplicationController
    def postcode
      results = OsPlacesService.run(params[:postcode]).results
      render json: { "results" => results }
    end
  end
end
