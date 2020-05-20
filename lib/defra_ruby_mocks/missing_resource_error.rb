# frozen_string_literal: true

module DefraRubyMocks
  class MissingRegistrationError < StandardError
    def initialize(reference)
      super("Could not find registration: #{reference}")
    end
  end
end
