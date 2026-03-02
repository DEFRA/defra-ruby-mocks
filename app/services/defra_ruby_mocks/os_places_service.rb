# frozen_string_literal: true

module DefraRubyMocks
  class OsPlacesService < BaseService
    # Mock addresses in OS Places API DPA format, keyed by normalized postcode
    MOCK_ADDRESSES = {
      "BS15AH" => [
        {
          "DPA" => {
            "UPRN" => "340116",
            "ADDRESS" => "ENVIRONMENT AGENCY, HORIZON HOUSE, DEANERY ROAD, BRISTOL, BS1 5AH",
            "ORGANISATION_NAME" => "ENVIRONMENT AGENCY",
            "BUILDING_NAME" => "HORIZON HOUSE",
            "THOROUGHFARE_NAME" => "DEANERY ROAD",
            "POST_TOWN" => "BRISTOL",
            "POSTCODE" => "BS1 5AH",
            "X_COORDINATE" => 358_205.0,
            "Y_COORDINATE" => 172_708.0,
            "DEPENDENT_LOCALITY" => "",
            "MATCH" => 1.0,
            "MATCH_DESCRIPTION" => "EXACT",
            "LANGUAGE" => "EN",
            "LAST_UPDATE_DATE" => "2024-01-01",
            "ENTRY_DATE" => "2020-01-01",
            "BLPU_STATE_CODE" => "2",
            "BLPU_STATE_CODE_DESCRIPTION" => "In use",
            "CLASSIFICATION_CODE" => "CO01",
            "CLASSIFICATION_CODE_DESCRIPTION" => "Office / Work Studio",
            "POSTAL_ADDRESS_CODE" => "D",
            "POSTAL_ADDRESS_CODE_DESCRIPTION" => "A record which is linked to PAF",
            "LOGICAL_STATUS_CODE" => "1",
            "STATUS" => "APPROVED",
            "TOPOGRAPHY_LAYER_TOID" => "",
            "PARENT_UPRN" => "",
            "USRN" => ""
          }
        },
        {
          "DPA" => {
            "UPRN" => "340117",
            "ADDRESS" => "THRIVE RENEWABLES PLC, DEANERY ROAD, BRISTOL, BS1 5AH",
            "ORGANISATION_NAME" => "THRIVE RENEWABLES PLC",
            "BUILDING_NAME" => "",
            "THOROUGHFARE_NAME" => "DEANERY ROAD",
            "POST_TOWN" => "BRISTOL",
            "POSTCODE" => "BS1 5AH",
            "X_COORDINATE" => 358_130.0,
            "Y_COORDINATE" => 172_687.0,
            "DEPENDENT_LOCALITY" => "",
            "MATCH" => 1.0,
            "MATCH_DESCRIPTION" => "EXACT",
            "LANGUAGE" => "EN",
            "LAST_UPDATE_DATE" => "2024-01-01",
            "ENTRY_DATE" => "2020-01-01",
            "BLPU_STATE_CODE" => "2",
            "BLPU_STATE_CODE_DESCRIPTION" => "In use",
            "CLASSIFICATION_CODE" => "CO01",
            "CLASSIFICATION_CODE_DESCRIPTION" => "Office / Work Studio",
            "POSTAL_ADDRESS_CODE" => "D",
            "POSTAL_ADDRESS_CODE_DESCRIPTION" => "A record which is linked to PAF",
            "LOGICAL_STATUS_CODE" => "1",
            "STATUS" => "APPROVED",
            "TOPOGRAPHY_LAYER_TOID" => "",
            "PARENT_UPRN" => "",
            "USRN" => ""
          }
        }
      ]
    }.freeze

    def run(postcode)
      @postcode = normalize_postcode(postcode)
      self
    end

    def results
      MOCK_ADDRESSES.fetch(@postcode, [])
    end

    private

    def normalize_postcode(postcode)
      postcode.to_s.upcase.gsub(/\s+/, "")
    end
  end
end
