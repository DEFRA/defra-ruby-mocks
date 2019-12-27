# frozen_string_literal: true

module DefraRubyMocks
  RSpec.describe Configuration do
    let(:subject) { described_class.new }

    describe "#enable=" do
      context "when passed true as boolean" do
        it "sets enable to 'true'" do
          subject.enable = true

          expect(subject.enabled?).to be(true)
        end
      end

      context "when passed false as a boolean" do
        it "sets enable to 'false'" do
          subject.enable = false

          expect(subject.enabled?).to be(false)
        end
      end

      context "when passed true as string" do
        it "sets enable to 'true'" do
          subject.enable = "true"

          expect(subject.enabled?).to be(true)
        end
      end

      context "when passed false as a string" do
        it "sets enable to 'false'" do
          subject.enable = "false"

          expect(subject.enabled?).to be(false)
        end
      end
    end

    describe "#delay=" do
      context "when passed 200 as an integer" do
        it "sets delay to 200" do
          subject.delay = 200

          expect(subject.delay).to be(200)
        end
      end

      context "when passed 200 as a string" do
        it "sets delay to 200" do
          subject.delay = "200"

          expect(subject.delay).to be(200)
        end
      end

      context "when passed a string that's not a number" do
        it "sets delay to its default" do
          subject.delay = ""

          expect(subject.delay).to be(Configuration::DEFAULT_DELAY)
        end
      end

      context "when passed nil" do
        it "sets delay to its default" do
          subject.delay = nil

          expect(subject.delay).to be(Configuration::DEFAULT_DELAY)
        end
      end
    end
  end
end
