# frozen_string_literal: true

module DefraRubyMocks
  RSpec.describe Configuration do
    let(:subject) { described_class.new }

    describe "#enable=" do
      context "when passed true as boolean" do
        it "sets enable to 'true'" do
          subject.enable = true

          expect(subject.enable).to be(true)
        end
      end

      context "when passed false as a boolean" do
        it "sets enable to 'false'" do
          subject.enable = false

          expect(subject.enable).to be(false)
        end
      end

      context "when passed true as string" do
        it "sets enable to 'true'" do
          subject.enable = "true"

          expect(subject.enable).to be(true)
        end
      end

      context "when passed false as a string" do
        it "sets enable to 'false'" do
          subject.enable = "false"

          expect(subject.enable).to be(false)
        end
      end
    end
  end
end
