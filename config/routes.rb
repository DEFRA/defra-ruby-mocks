# frozen_string_literal: true

DefraRubyMocks::Engine.routes.draw do
  get "/company/:id",
      to: "company#show",
      as: "company",
      constraints: ->(_request) { DefraRubyMocks.configuration.enabled? }

  get "/worldpay/payments-service",
      to: "worldpay_api#payments_service",
      as: "worldpay_api_payments_service",
      constraints: ->(_request) { DefraRubyMocks.configuration.enabled? }

  get "/worldpay/dispatcher",
      to: "worldpay_api#dispatcher",
      as: "worldpay_api_dispatcher",
      constraints: ->(_request) { DefraRubyMocks.configuration.enabled? }

end
