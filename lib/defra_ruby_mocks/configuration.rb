# frozen_string_literal: true

module DefraRubyMocks
  class Configuration

    DEFAULT_DELAY = 1000

    attr_accessor :worldpay_admin_code, :worldpay_mac_secret, :worldpay_merchant_code, :worldpay_domain, :govpay_domain
    attr_reader :delay

    def initialize
      @enable = false
      @delay = DEFAULT_DELAY
    end

    # Controls whether the mocks are enabled. Only if set to true will the mock
    # pages be accessible
    def enable=(arg)
      # We implement our own setter to handle values being passed in as strings
      # rather than booleans
      parsed = arg.to_s.downcase

      @enable = parsed == "true"
    end

    def enabled?
      @enable
    end

    # Set a delay in milliseconds for the mocks to respond.
    # Defaults to 1000 (1 sec)
    def delay=(arg)
      # We implement our own setter to handle values being passed in as strings
      # rather than integers
      @delay = arg.to_i

      @delay = DEFAULT_DELAY if @delay.zero?
    end
  end
end
