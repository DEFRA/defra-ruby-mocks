# frozen_string_literal: true

module Helpers
  module Configuration
    def self.prep_for_tests(delay = 100)
      DefraRubyMocks.configure do |config|
        config.enable = true
        config.delay = delay
      end
    end
  end
end
