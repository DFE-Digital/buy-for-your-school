require "rails_helper"

RSpec.describe SaveAnswer do
  describe "#call" do
    it "updates the answer with the params" do
      answer = create(:short_text_answer)
      params = ActionController::Parameters.new(response: "A little text").permit!

      result = described_class.new(answer:).call(params:)

      expect(result.success?).to be(true)
      expect(result.object.response).to eql("A little text")
    end

    it "checks to see if any other steps need to be updated" do
      answer = create(:short_text_answer)

      toggle_service = instance_double(ToggleAdditionalSteps)
      allow(ToggleAdditionalSteps).to receive(:new).with(step: answer.step).and_return(toggle_service)
      expect(toggle_service).to receive(:call)

      described_class.new(answer:).call(params: {})
    end

    context "when the step is a checkbox question" do
      it "updates the answer with the checkbox_params" do
        answer = create(:checkbox_answers)
        params = ActionController::Parameters.new(response: %w[A B]).permit!

        result = described_class.new(answer:).call(params:)

        expect(result.success?).to be(true)
        expect(result.object.response).to eql(%w[A B])
      end
    end

    context "when the step is a date question" do
      it "updates the answer with the date_params" do
        answer = build(:single_date_answer, response: nil)
        date = Date.new(2000, 1, 29)
        params = { response: date }

        result = described_class.new(answer:).call(params:)

        expect(result.success?).to be(true)
        expect(result.object.response).to eql(date)
      end
    end

    context "when the answer is invalid" do
      it "does not try to save the answer" do
        answer = create(:checkbox_answers)

        allow(answer).to receive(:valid?).and_return(false)
        expect(answer).not_to receive(:save)

        described_class.new(answer:).call(params: {})
      end

      it "returns a failed result" do
        answer = create(:short_text_answer)
        params = ActionController::Parameters.new(response: "A").permit!

        allow(answer).to receive(:valid?).and_return(false)

        result = described_class.new(answer:).call(params:)

        expect(result.success?).to be(false)
      end
    end

    context "when the associated journey is unstarted" do
      it "updates the journey to be started" do
        step = create(:step, :radio)
        journey = step.journey
        journey.update!(started: false)
        answer = create(:short_text_answer, step:)

        _result = described_class.new(answer:).call(params: {})

        expect(journey.reload.started).to eq(true)
      end
    end

    context "when the answer includes script characters" do
      it "removes them from the answer that is then saved" do
        answer = create(:short_text_answer)
        params = ActionController::Parameters.new(response: "<script>alert('problem');</script>A little text").permit!

        expect_any_instance_of(StringSanitiser).to receive(:call).and_call_original

        result = described_class.new(answer:).call(params:)

        expect(result.object.response).to eql("alert('problem');A little text")
      end
    end
  end
end
