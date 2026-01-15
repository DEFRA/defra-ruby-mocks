# frozen_string_literal: true

module DefraRubyMocks
  class OsPlacesController < ::DefraRubyMocks::ApplicationController
    def postcode
      # Return array directly - the gem assigns JSON.parse(response) to results
      @results = OsPlacesService.run(params[:postcode]).results
      render json: @results
    end
  end
end
