# frozen_string_literal: true

DefraRubyMocks::Engine.routes.draw do
  get "/company/:id",
      to: "company#show",
      as: "company",
      constraints: ->(_request) { DefraRubyMocks.configuration.enabled? }

  get "/worldpay",
      to: "worldpay#show",
      as: "worldpay",
      constraints: ->(_request) { DefraRubyMocks.configuration.enabled? }
end
