# frozen_string_literal: true

module DefraRubyMocks
  class MissingResourceError < StandardError
    def initialize(reference)
      super("Could not find resource: #{reference}")
    end
  end
end
