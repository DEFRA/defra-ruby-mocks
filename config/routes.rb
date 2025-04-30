# frozen_string_literal: true

DefraRubyMocks::Engine.routes.draw do # rubocop:disable Metrics/BlockLength
  get "/company/:id",
      to: "company#show",
      as: "company",
      constraints: ->(_request) { DefraRubyMocks.configuration.enabled? }

  get "/company/:id/officers",
      to: "company#officers",
      as: "company_officers",
      constraints: ->(_request) { DefraRubyMocks.configuration.enabled? }

  post "/govpay/v1/payments",
       to: "govpay#create_payment",
       as: "govpay_create_payment",
       constraints: ->(_request) { DefraRubyMocks.configuration.enabled? }

  get "/govpay/v1/payments/secure/:uuid",
      to: "govpay#next_url",
      as: "govpay_next_url",
      constraints: ->(_request) { DefraRubyMocks.configuration.enabled? }

  get "/govpay/v1/payments/:payment_id",
      to: "govpay#payment_details",
      as: "govpay_payment_details",
      constraints: ->(_request) { DefraRubyMocks.configuration.enabled? }

  post "/govpay/v1/payments/:payment_id/refunds",
       to: "govpay#create_refund",
       as: "govpay_create_refund",
       constraints: ->(_request) { DefraRubyMocks.configuration.enabled? }

  get "/govpay/v1/payments/:payment_id/refunds/:refund_id",
      to: "govpay#refund_details",
      as: "govpay_refund_details",
      constraints: ->(_request) { DefraRubyMocks.configuration.enabled? }

  # test helpers, not mocks:
  get "/govpay/v1/payments/set_test_payment_response_status/:status",
      to: "govpay_test_helpers#set_test_payment_response_status",
      as: "govpay_set_test_payment_response_status",
      constraints: ->(_request) { DefraRubyMocks.configuration.enabled? }

  get "/govpay/v1/payments/set_test_refund_response_status/:status",
      to: "govpay_test_helpers#set_test_refund_response_status",
      as: "govpay_set_test_refund_response_status",
      constraints: ->(_request) { DefraRubyMocks.configuration.enabled? }

  post "/govpay/v1/payments/:govpay_id/send_payment_webhook",
       to: "govpay_test_helpers#send_payment_webhook",
       as: "send_payment_webhook",
       constraints: ->(_request) { DefraRubyMocks.configuration.enabled? }

  post "/govpay/v1/payments/:govpay_id/send_refund_webhook",
       to: "govpay_test_helpers#send_refund_webhook",
       as: "send_refund_webhook",
       constraints: ->(_request) { DefraRubyMocks.configuration.enabled? }
end
