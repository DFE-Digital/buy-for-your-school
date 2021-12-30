require "spec_helper"
require_relative "../../lib/feature_flags"

describe FeatureFlags do
  describe "#enabled?" do
    subject(:feature_flags) { described_class.new(configuration) }

    describe "checking if feature_x is enabled" do
      context "when configuration key for feature_x is set to true" do
        let(:configuration) { { feature_x: true } }

        it "returns true" do
          expect(feature_flags.enabled?(:feature_x)).to be(true)
        end
      end

      context "when configuration key for feature_x is set to false" do
        let(:configuration) { { feature_x: false } }

        it "returns false" do
          expect(feature_flags.enabled?(:feature_x)).to be(false)
        end
      end

      context "when configuration key for feature_x is not defined" do
        let(:configuration) { { feature_x: false } }

        it "returns false" do
          expect(feature_flags.enabled?(:feature_x)).to be(false)
        end
      end
    end
  end
end