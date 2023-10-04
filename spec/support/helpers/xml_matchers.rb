# frozen_string_literal: true

require "rspec/expectations"

RSpec::Matchers.define :be_xml do
  match do

    Nokogiri::XML(actual, &:strict)

    true
  rescue Nokogiri::XML::SyntaxError
    false

  end

  failure_message do |actual|
    "expected that \"#{actual}\" would be a valid XML document"
  end
end
