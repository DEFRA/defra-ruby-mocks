# frozen_string_literal: true

module DefraRuby
  module Mocks
    class BaseService
      def self.run(attrs = nil)
        new.run(attrs)
      end
    end
  end
end
