# frozen_string_literal: true

module DefraRubyMocks
  class WorldpayController < ::DefraRubyMocks::ApplicationController

    before_action :set_default_response_format

    def payments_service
      @values = WorldpayRequestHandlerService.run(convert_request_body_to_xml)

      render_payment_response if @values[:request_type] == :payment
      render_refund_response if @values[:request_type] == :refund
    rescue StandardError
      head 500
    end

    def dispatcher
      @response = WorldpayResponseService.run(
        success_url: params[:successURL],
        failure_url: params[:failureURL],
        pending_url: params[:pendingURL],
        cancel_url: params[:cancelURL],
        error_url: params[:errorURL]
      )

      if @response.status == :STUCK
        render formats: :html, action: "stuck", layout: false
      else
        redirect_to @response.url
      end
    rescue StandardError
      head 500
    end

    private

    def set_default_response_format
      request.format = :xml
    end

    def convert_request_body_to_xml
      Nokogiri::XML(request.body.read)
    end

    def render_payment_response
      render "defra_ruby_mocks/worldpay/payment_request"
    end

    def render_refund_response
      render "defra_ruby_mocks/worldpay/refund_request"
    end

  end
end
