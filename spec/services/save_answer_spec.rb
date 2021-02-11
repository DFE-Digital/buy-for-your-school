require "rails_helper"

RSpec.describe SaveAnswer do
  describe "#call" do
    it "updates the answer with the answer_params" do
      answer = create(:short_text_answer)
      params = ActionController::Parameters.new(response: "A little text").permit!

      result = described_class.new(answer: answer).call(answer_params: params)

      expect(result.success?).to eql(true)
      expect(result.object.response).to eql("A little text")
    end

    it "checks to see if any other steps need to be updated" do
      answer = create(:short_text_answer)

      expect(answer.step).to receive(:check_to_show_additional_step!)

      described_class.new(answer: answer).call(answer_params: {})
    end

    context "when the step is a checkbox question" do
      it "updates the answer with the checkbox_params" do
        answer = create(:checkbox_answers)
        params = ActionController::Parameters.new(response: ["A", "B"]).permit!

        result = described_class.new(answer: answer).call(checkbox_params: params)

        expect(result.success?).to eql(true)
        expect(result.object.response).to eql(["A", "B"])
      end
    end

    context "when the answer is invalid" do
      it "does not try to save the answer" do
        answer = create(:checkbox_answers)

        allow(answer).to receive(:valid?).and_return(false)
        expect(answer).not_to receive(:save)

        described_class.new(answer: answer).call(answer_params: {})
      end

      it "returns a failed result" do
        answer = create(:short_text_answer)
        params = ActionController::Parameters.new(response: "A").permit!

        allow(answer).to receive(:valid?).and_return(false)

        result = described_class.new(answer: answer).call(answer_params: params)

        expect(result.success?).to eql(false)
      end
    end
  end
end
