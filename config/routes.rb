# frozen_string_literal: true

DefraRuby::Mocks::Engine.routes.draw do
  get "/test",
      to: "test#show",
      as: "test"
end
