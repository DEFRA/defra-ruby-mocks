# frozen_string_literal: true

require "defra_ruby_mocks/engine"

module DefraRubyMocks
  # Enable the ability to configure the gem from its host app, rather than
  # reading directly from env vars. Derived from
  # https://robots.thoughtbot.com/mygem-configure-block
  class << self
    attr_writer :configuration

    def configuration
      @configuration ||= Configuration.new
    end

    # Added for testing. Without we cannot test both a config object with and
    # with set values in the same rspec session
    def reset_configuration
      @configuration = nil
    end
  end

  def self.configure
    yield(configuration)
  end

  class Configuration
    # Set whether the mocks are enabled. Only if set to true will the mock
    # pages be accessible
    attr_accessor :enabled
    # Set a delay in milliseconds for the mocks to respond.
    # Defaults to 1000 (1 sec)
    attr_accessor :delay

    def initialize
      @enabled = false
      @delay = 1000
    end
  end
end
