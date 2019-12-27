# frozen_string_literal: true

module DefraRubyMocks
  class Configuration
    # Controls whether the mocks are enabled. Only if set to true will the mock
    # pages be accessible
    attr_reader :enable
    # Set a delay in milliseconds for the mocks to respond.
    # Defaults to 1000 (1 sec)
    attr_accessor :delay

    def initialize
      @enable = false
      @delay = 1000
    end

    # We implement our own setter to handle values being passed in as strings
    # rather than booleans
    def enable=(arg)
      parsed = arg.to_s.downcase

      @enable = parsed == "true"
    end
  end
end
