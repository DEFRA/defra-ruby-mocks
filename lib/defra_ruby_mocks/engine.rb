# frozen_string_literal: true

require_relative "configuration"
require_relative "invalid_config_error"
require_relative "missing_resource_error"

module DefraRubyMocks
  class Engine < ::Rails::Engine
    isolate_namespace DefraRubyMocks

    initializer "DefraRubyMocks.set_logger" do
      ActiveSupport.on_load(:after_initialize) do
        DefraRubyMocks::Engine.config.logger = Rails.logger
      end
    end

    config.generators do |g|
      g.test_framework :rspec
    end

    # Skip SSL for mocks
    initializer "mocks_engine.middleware" do |_app|
      require "middleware/skip_ssl_for_mocks_engine"
    end
  end
end
