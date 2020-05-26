# frozen_string_literal: true

module DefraRubyMocks
  class WorldpayController < ApplicationController

    def stuck
      @response = cookies[:worldpay_mock].blank? ? nil : JSON.parse(cookies[:worldpay_mock])

      render formats: :html, action: "stuck", layout: false
    rescue StandardError
      head 500
    end

  end
end
