# frozen_string_literal: true

module DefraRubyMocks
  class WasteCarriersResourceService < BaseService

    def run(reference:)
      @reference = reference

      raise(MissingResourceError, @reference) if resource.nil?

      WasteCarriersResource.new(resource, order, company_name)
    end

    private

    WasteCarriersResource = Struct.new(:resource, :order, :company_name)

    def resource
      @_resource ||= locate_transient_registration || locate_completed_registration
    end

    def locate_transient_registration
      "WasteCarriersEngine::TransientRegistration"
        .constantize
        .where(token: @reference)
        .first
    end

    def locate_completed_registration
      "WasteCarriersEngine::Registration"
        .constantize
        .where(reg_uuid: @reference)
        .first
    end

    def locate_original_registration(reg_identifier)
      "WasteCarriersEngine::Registration"
        .constantize
        .where(reg_identifier: reg_identifier)
        .first
    end

    def order
      @_order ||= resource.finance_details&.orders&.order_by(dateCreated: :desc)&.first
    end

    def company_name
      if resource.class.to_s == "WasteCarriersEngine::OrderCopyCardsRegistration"
        locate_original_registration(resource.reg_identifier).company_name&.downcase
      else
        resource.company_name&.downcase
      end
    end
  end
end
