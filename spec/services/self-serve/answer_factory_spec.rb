require "rails_helper"

RSpec.describe AnswerFactory do
  describe "#call" do
    context "when the step is for an unknown question type" do
      it "raises an unexpected question type error" do
        step = create(:step, options: nil, contentful_model: "question", contentful_type: "telepathy")
        expect {
          described_class.new(step:).call
        }.to raise_error(AnswerFactory::UnexpectedQuestionType)
      end
    end

    context "when the step is for radios" do
      it "returns a new RadioAnswer object" do
        step = create(:step, :radio)
        result = described_class.new(step:).call
        expect(result).to be_kind_of(RadioAnswer)
      end
    end

    context "when the step is for short_text" do
      it "returns a new ShortTextAnswer object" do
        step = create(:step, :short_text)
        result = described_class.new(step:).call
        expect(result).to be_kind_of(ShortTextAnswer)
      end
    end

    context "when the step is for long_text" do
      it "returns a new LongTextAnswer object" do
        step = create(:step, :long_text)
        result = described_class.new(step:).call
        expect(result).to be_kind_of(LongTextAnswer)
      end
    end
  end

  context "when the step is for number" do
    it "returns a new NumberAnswer object" do
      step = create(:step, :number)
      result = described_class.new(step:).call
      expect(result).to be_kind_of(NumberAnswer)
    end
  end

  context "when the step is for currency" do
    it "returns a new CurrencyAnswer object" do
      step = create(:step, :currency)
      result = described_class.new(step:).call
      expect(result).to be_kind_of(CurrencyAnswer)
    end
  end
end
