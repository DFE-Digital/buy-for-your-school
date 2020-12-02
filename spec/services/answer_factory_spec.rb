require "rails_helper"

RSpec.describe AnswerFactory do
  describe "#call" do
    context "when the step is for radios" do
      it "returns a new RadioAnswer object" do
        step = create(:step, :radio)
        result = described_class.new(step: step).call
        expect(result).to be_kind_of(RadioAnswer)
      end
    end

    context "when the step is for short_text" do
      it "returns a new ShortTextAnswer object" do
        step = create(:step, :short_text)
        result = described_class.new(step: step).call
        expect(result).to be_kind_of(ShortTextAnswer)
      end
    end

    context "when the step is for long_text" do
      it "returns a new LongTextAnswer object" do
        step = create(:step, :long_text)
        result = described_class.new(step: step).call
        expect(result).to be_kind_of(LongTextAnswer)
      end
    end
  end
end
