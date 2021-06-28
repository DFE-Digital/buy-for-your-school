require "rails_helper"

RSpec.describe StepPresenter do
  describe "#statement?" do
    context "when the contentful model is 'staticContent'" do
      it "returns true" do
        step = build(:step, :static_content)
        presenter = described_class.new(step)
        expect(presenter.statement?).to be true
      end
    end

    context "when the contentful model is NOT 'staticContent'" do
      it "returns false" do
        step = build(:step, :radio)
        presenter = described_class.new(step)
        expect(presenter.statement?).to be false
      end
    end
  end

  describe "#question?" do
    context "when the contentful model is 'question'" do
      it "returns true" do
        step = build(:step, :radio)
        presenter = described_class.new(step)
        expect(presenter.question?).to be true
      end
    end

    context "when the contentful model is NOT 'question'" do
      it "returns false" do
        step = build(:step, :static_content)
        presenter = described_class.new(step)
        expect(presenter.question?).to be false
      end
    end
  end

  describe "#response" do
    it "returns a decorated answer" do
      answer = create(:currency_answer)
      presenter = described_class.new(answer.step)
      expect(presenter.response).to eql "£1,000.01"

      answer = create(:checkbox_answers)
      presenter = described_class.new(answer.step)
      expect(presenter.response).to eql "Breakfast, Lunch"
    end
  end

  describe "#status_id" do
    it "returns the uuid appended by status" do
      step = create(:step, :currency)
      presenter = described_class.new(step)
      expect(presenter.status_id).to match(/[a-f0-9]{8}(-[a-f0-9]{4}){3}-[a-f0-9]{12}-status/)
    end
  end

  describe "#help_text_html" do
    it "returns the uuid appended by status" do
      step = create(:step, :currency)
      presenter = described_class.new(step)
      expect(presenter.help_text_html).to include("<p>Choose the primary colour closest to your choice</p>\n")
    end
  end
end
