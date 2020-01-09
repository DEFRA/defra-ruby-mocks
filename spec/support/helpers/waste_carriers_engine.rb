# frozen_string_literal: true

module WasteCarriersEngine
  class Registration
    def self.where(*)
      true
    end
  end
  class TransientRegistration
    def self.where(*)
      true
    end
  end
end
