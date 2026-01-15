# frozen_string_literal: true

module DefraRubyMocks
  class OsPlacesService < BaseService
    # Mock addresses keyed by normalized postcode (uppercase, no spaces)
    MOCK_ADDRESSES = {
      "BS15AH" => [
        {
          "moniker" => "340116",
          "uprn" => "340116",
          "lines" => ["ENVIRONMENT AGENCY", "DEANERY ROAD"],
          "town" => "BRISTOL",
          "postcode" => "BS1 5AH",
          "easting" => "358205",
          "northing" => "172708",
          "country" => "",
          "dependentLocality" => "",
          "dependentThroughfare" => "",
          "administrativeArea" => "BRISTOL",
          "localAuthorityUpdateDate" => "",
          "royalMailUpdateDate" => "",
          "partial" => "ENVIRONMENT AGENCY, HORIZON HOUSE, DEANERY ROAD, BRISTOL, BS1 5AH",
          "subBuildingName" => "",
          "buildingName" => "HORIZON HOUSE",
          "thoroughfareName" => "DEANERY ROAD",
          "organisationName" => "ENVIRONMENT AGENCY",
          "buildingNumber" => "",
          "postOfficeBoxNumber" => "",
          "departmentName" => "",
          "doubleDependentLocality" => ""
        },
        {
          "moniker" => "340117",
          "uprn" => "340117",
          "lines" => ["THRIVE RENEWABLES PLC", "DEANERY ROAD"],
          "town" => "BRISTOL",
          "postcode" => "BS1 5AH",
          "easting" => "358130",
          "northing" => "172687",
          "country" => "",
          "dependentLocality" => "",
          "dependentThroughfare" => "",
          "administrativeArea" => "BRISTOL",
          "localAuthorityUpdateDate" => "",
          "royalMailUpdateDate" => "",
          "partial" => "THRIVE RENEWABLES PLC, DEANERY ROAD, BRISTOL, BS1 5AH",
          "subBuildingName" => "",
          "buildingName" => "",
          "thoroughfareName" => "DEANERY ROAD",
          "organisationName" => "THRIVE RENEWABLES PLC",
          "buildingNumber" => "",
          "postOfficeBoxNumber" => "",
          "departmentName" => "",
          "doubleDependentLocality" => ""
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
