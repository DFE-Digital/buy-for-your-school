RSpec.describe RequestForm do
  subject(:form) { described_class.new(user:) }

  let(:user) { create(:user) }

  describe "#confidence_levels" do
    it "returns the confidence level values" do
      expect(form.confidence_levels).to eq %w[very_confident confident slightly_confident somewhat_confident not_at_all_confident not_applicable]
    end
  end

  describe "#about_procurement?" do
    context "when we have a procurement_choice" do
      context "and it is not_about_procurement" do
        subject(:form) { described_class.new(user:, procurement_choice: "not_about_procurement") }

        it "returns false" do
          expect(form.about_procurement?).to eq false
        end
      end

      context "and it is not not_about_procurement" do
        subject(:form) { described_class.new(user:, procurement_choice: "yes") }

        it "returns true" do
          expect(form.about_procurement?).to eq true
        end
      end
    end

    context "when we do not have a procurement_choice" do
      it "returns the value of about_procurement" do
        form = described_class.new(user:, about_procurement: true)
        expect(form.about_procurement?).to eq true

        form = described_class.new(user:, about_procurement: false)
        expect(form.about_procurement?).to eq false

        form = described_class.new(user:)
        expect(form.about_procurement?).to eq nil
      end
    end
  end

  describe "#special_requirements_choice" do
    context "when there are validation errors" do
      subject(:form) { described_class.new(user:, special_requirements_choice: "yes", messages: { a: :b }) }

      it "returns the provided value" do
        expect(form.special_requirements_choice).to eq "yes"
      end
    end

    context "when there are no validation errors" do
      it "infers the choice from the special_requirements value" do
        form = described_class.new(user:, special_requirements: "reqs", messages: {})
        expect(form.special_requirements_choice).to eq "yes"

        form = described_class.new(user:, special_requirements: "", messages: {})
        expect(form.special_requirements_choice).to eq "no"
      end
    end
  end

  describe "#data" do
    it "excludes radio button choices" do
      form = described_class.new(user:, procurement_choice: "a", special_requirements_choice: "b")
      expect(form.data).not_to include "procurement_choice"
      expect(form.data).not_to include "special_requirements_choice"
    end

    context "when procurement_amount is provided" do
      context "and the request is about a procurement" do
        subject(:form) { described_class.new(user:, procurement_amount: "55.12", procurement_choice: "yes") }

        it "includes the procurement amount" do
          expect(form.data[:procurement_amount]).to eq "55.12"
        end

        it "includes sets about_procurement to true" do
          expect(form.data[:about_procurement]).to eq true
        end
      end

      context "and the request is not about a procurement" do
        subject(:form) { described_class.new(user:, procurement_choice: "not_about_procurement") }

        it "sets the procurement amount to nil" do
          expect(form.data[:procurement_amount]).to eq nil
        end

        it "sets about_procurement to false" do
          expect(form.data[:about_procurement]).to eq false
        end
      end
    end

    context "when procurement_amount is not provided" do
      it "does not include procurement_amount" do
        expect(form.data).not_to include "procurement_amount"
      end
    end

    context "when confidence_level is provided" do
      context "and the request is about a procurement" do
        subject(:form) { described_class.new(user:, confidence_level: "confident", about_procurement: true) }

        it "includes the confidence level" do
          expect(form.data[:confidence_level]).to eq "confident"
        end
      end

      context "and the request is not about a procurement" do
        subject(:form) { described_class.new(user:, confidence_level: "confident", about_procurement: false) }

        it "sets the confidence level to nil" do
          expect(form.data[:confidence_level]).to eq nil
        end
      end
    end

    context "when confidence_level is not provided" do
      it "does not include confidence_level" do
        expect(form.data).not_to include "confidence_level"
      end
    end
  end
end
