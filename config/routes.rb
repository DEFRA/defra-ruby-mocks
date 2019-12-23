# frozen_string_literal: true

DefraRubyMocks::Engine.routes.draw do
  get "/test",
      to: "test#show",
      as: "test"
end
