# frozen_string_literal: true

module DefraRubyMocks
  RSpec.describe Configuration do
    let(:subject) { described_class.new }

    describe "#enabled=" do
      context "when passed true as boolean" do
        it "sets enabled to 'true'" do
          subject.enabled = true

          expect(subject.enabled).to be(true)
        end
      end

      context "when passed false as a boolean" do
        it "sets enabled to 'false'" do
          subject.enabled = false

          expect(subject.enabled).to be(false)
        end
      end

      context "when passed true as string" do
        it "sets enabled to 'true'" do
          subject.enabled = "true"

          expect(subject.enabled).to be(true)
        end
      end

      context "when passed false as a string" do
        it "sets enabled to 'false'" do
          subject.enabled = "false"

          expect(subject.enabled).to be(false)
        end
      end
    end
  end
end
