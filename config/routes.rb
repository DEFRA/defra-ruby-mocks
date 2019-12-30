# frozen_string_literal: true

DefraRubyMocks::Engine.routes.draw do
  get "/company/:id",
      to: "company#show",
      as: "company",
      constraints: ->(_request) { DefraRubyMocks.configuration.enabled? }

  get "/worldpay/payments-service",
      to: "worldpay#payments_service",
      as: "worldpay_payments_service",
      constraints: ->(_request) { DefraRubyMocks.configuration.enabled? }
end
