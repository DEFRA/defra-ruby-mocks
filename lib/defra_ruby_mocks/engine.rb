# frozen_string_literal: true

require_relative "configuration"

module DefraRubyMocks
  class Engine < ::Rails::Engine
    isolate_namespace DefraRubyMocks

    config.generators do |g|
      g.test_framework :rspec
    end
  end
end
