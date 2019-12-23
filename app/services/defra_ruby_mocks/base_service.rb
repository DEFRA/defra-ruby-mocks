# frozen_string_literal: true

module DefraRubyMocks
  class BaseService
    def self.run(attrs = nil)
      new.run(attrs)
    end
  end
end
