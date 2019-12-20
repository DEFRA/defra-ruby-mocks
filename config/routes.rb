# frozen_string_literal: true

DefraRubyMocks::Engine.routes.draw do
  get "/company/:id",
      to: "company#show",
      as: "company"

  get "/test",
      to: "test#show",
      as: "test"
end
