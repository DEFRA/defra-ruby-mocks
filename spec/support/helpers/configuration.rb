# frozen_string_literal: true

module Helpers
  module Configuration
    def self.prep_for_tests(delay = 100)
      DefraRubyMocks.reset_configuration
      DefraRubyMocks.configure do |config|
        config.enable = true
        config.delay = delay
      end
    end

    def self.reset_for_tests
      DefraRubyMocks.reset_configuration
    end
  end
end
