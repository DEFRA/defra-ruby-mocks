# frozen_string_literal: true

DefraRubyMocks::Engine.routes.draw do
  get "/company/:id",
      to: "company#show",
      as: "company"
end
