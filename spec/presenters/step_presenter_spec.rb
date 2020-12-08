require "rails_helper"

RSpec.describe StepPresenter do
  describe "#question?" do
    context "when the contentful model is 'question'" do
      it "returns true" do
        step = build(:step, :radio, contentful_model: "question")
        presenter = described_class.new(step)
        expect(presenter.question?).to eq(true)
      end
    end

    context "when the contentful model is NOT 'question'" do
      it "returns false" do
        step = build(:step, contentful_model: "staticContent")
        presenter = described_class.new(step)
        expect(presenter.question?).to eq(false)
      end
    end
  end
end
