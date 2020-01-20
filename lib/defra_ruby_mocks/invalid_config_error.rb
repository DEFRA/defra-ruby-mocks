# frozen_string_literal: true

module DefraRubyMocks
  class InvalidConfigError < StandardError
    def initialize(attribute)
      super("Mocks configuration contains a problem attribute: #{attribute}")
    end
  end
end
