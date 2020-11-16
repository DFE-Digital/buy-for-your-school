require "rails_helper"

RSpec.describe AnswerFactory do
  describe "#call" do
    context "when the question is for an unexpected type" do
      it "returns a plain Answer object" do
        question = create(:question, contentful_type: "foo")
        result = described_class.new(question: question).call
        expect(result).to be_kind_of(Answer)
      end
    end

    context "when the question is for radios" do
      it "returns a new RadioAnswer object" do
        question = create(:question, :radio)
        result = described_class.new(question: question).call
        expect(result).to be_kind_of(RadioAnswer)
      end
    end

    context "when the question is for short_text" do
      it "returns a new ShortTextAnswer object" do
        question = create(:question, :short_text)
        result = described_class.new(question: question).call
        expect(result).to be_kind_of(ShortTextAnswer)
      end
    end
  end
end
