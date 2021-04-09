require "rails_helper"

RSpec.describe SaveAnswer do
  describe "#call" do
    it "updates the answer with the params" do
      answer = create(:short_text_answer)
      params = ActionController::Parameters.new(response: "A little text").permit!

      result = described_class.new(answer: answer).call(params: params)

      expect(result.success?).to eql(true)
      expect(result.object.response).to eql("A little text")
    end

    it "checks to see if any other steps need to be updated" do
      answer = create(:short_text_answer)

      toggle_service = instance_double(ToggleAdditionalSteps)
      expect(ToggleAdditionalSteps).to receive(:new).with(step: answer.step).and_return(toggle_service)
      expect(toggle_service).to receive(:call)

      described_class.new(answer: answer).call(params: {})
    end

    context "when the step is a checkbox question" do
      it "updates the answer with the checkbox_params" do
        answer = create(:checkbox_answers)
        params = ActionController::Parameters.new(response: ["A", "B"]).permit!

        result = described_class.new(answer: answer).call(params: params)

        expect(result.success?).to eql(true)
        expect(result.object.response).to eql(["A", "B"])
      end
    end

    context "when the step is a date question" do
      it "updates the answer with the date_params" do
        answer = build(:single_date_answer, response: nil)
        date = Date.new(2000, 1, 29)
        params = {response: date}

        result = described_class.new(answer: answer).call(params: params)

        expect(result.success?).to eql(true)
        expect(result.object.response).to eql(date)
      end
    end

    context "when the answer is invalid" do
      it "does not try to save the answer" do
        answer = create(:checkbox_answers)

        allow(answer).to receive(:valid?).and_return(false)
        expect(answer).not_to receive(:save)

        described_class.new(answer: answer).call(params: {})
      end

      it "returns a failed result" do
        answer = create(:short_text_answer)
        params = ActionController::Parameters.new(response: "A").permit!

        allow(answer).to receive(:valid?).and_return(false)

        result = described_class.new(answer: answer).call(params: params)

        expect(result.success?).to eql(false)
      end
    end

    context "when the associated journey is unstarted" do
      it "updates the journey to be started" do
        journey = create(:journey, started: false)
        step = create(:step, :radio, journey: journey)
        answer = create(:short_text_answer, step: step)

        _result = described_class.new(answer: answer).call(answer_params: {})

        expect(journey.reload.started).to eq(true)
      end
    end
  end
end
