# frozen_string_literal: true

module DefraRubyMocks
  class ApplicationController < ActionController::Base
    protect_from_forgery with: :exception
    before_action :delay_response

    private

    def delay_response
      # sleep() expects the time to be specified in seconds, but we allow delay
      # to be specified in milliseconds. Dividing by 1000 converts milliseconds
      # to seconds.
      sleep(DefraRubyMocks.configuration.delay / 1000)
    end
  end
end
