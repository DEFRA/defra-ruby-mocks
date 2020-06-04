# frozen_string_literal: true

module DefraRubyMocks
  class WorldpayController < ::DefraRubyMocks::ApplicationController

    def stuck
      @response = cookies[:defra_ruby_mocks].blank? ? nil : JSON.parse(cookies[:defra_ruby_mocks])

      render formats: :html, action: "stuck", layout: false
    rescue StandardError
      head 500
    end

  end
end
