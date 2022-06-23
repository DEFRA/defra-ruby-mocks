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

  post "/govpay/v1/payments",
       to: "govpay#create_payment",
       as: "govpay_create_payment",
       constraints: ->(_request) { DefraRubyMocks.configuration.enabled? }

  get "/govpay/v1/payments/:payment_id",
      to: "govpay#payment_details",
      as: "govpay_payment_details",
      constraints: ->(_request) { DefraRubyMocks.configuration.enabled? }
end
