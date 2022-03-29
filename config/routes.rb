# frozen_string_literal: true

DefraRubyMocks::Engine.routes.draw do
  get "/company/:id",
      to: "company#show",
      as: "company",
      constraints: ->(_request) { DefraRubyMocks.configuration.enabled? }

  get "/company/:id/officers",
      to: "company#officers",
      as: "company_officers",
      constraints: ->(_request) { DefraRubyMocks.configuration.enabled? }

  post "/worldpay/payments-service",
      to: "worldpay#payments_service",
      as: "worldpay_payments_service",
      constraints: ->(_request) { DefraRubyMocks.configuration.enabled? }

  get "/worldpay/dispatcher",
      to: "worldpay#dispatcher",
      as: "worldpay_dispatcher",
      constraints: ->(_request) { DefraRubyMocks.configuration.enabled? }

end
