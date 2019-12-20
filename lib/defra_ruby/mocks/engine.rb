# frozen_string_literal: true

module DefraRuby
  module Mocks
    class Engine < ::Rails::Engine
      isolate_namespace DefraRuby::Mocks

      config.generators do |g|
        g.test_framework :rspec
      end
    end
  end
end
