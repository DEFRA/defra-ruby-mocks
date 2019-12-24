# frozen_string_literal: true

require "rails_helper"

RSpec.describe DefraRubyMocks do
  describe "VERSION" do
    it "is a version string in the correct format" do
      expect(DefraRubyMocks::VERSION).to be_a(String)
      expect(DefraRubyMocks::VERSION).to match(/\d+\.\d+\.\d+/)
    end
  end

  describe "#configuration" do
    before(:each) { Helpers::Configuration.reset_for_tests }

    context "when the host app has not provided configuration" do
      let(:enabled) { false }
      let(:delay) { 1000 }

      it "returns a DefraRubyMocks::Configuration instance with default values" do
        expect(described_class.configuration).to be_an_instance_of(DefraRubyMocks::Configuration)

        expect(described_class.configuration.enabled).to eq(enabled)
        expect(described_class.configuration.delay).to eq(delay)
      end
    end

    context "when the host app has provided configuration" do
      let(:enabled) { true }
      let(:delay) { 2000 }

      it "returns an DefraRubyMocks::Configuration instance with matching values" do
        described_class.configure do |config|
          config.enabled = enabled
          config.delay = delay
        end

        expect(described_class.configuration).to be_an_instance_of(DefraRubyMocks::Configuration)
        expect(described_class.configuration.enabled).to eq(enabled)
        expect(described_class.configuration.delay).to eq(delay)
      end
    end
  end
end
