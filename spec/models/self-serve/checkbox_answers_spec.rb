RSpec.describe CheckboxAnswers, type: :model do
  it "belongs to a step" do
    association = described_class.reflect_on_association(:step)
    expect(association.macro).to eq(:belongs_to)
  end

  describe "#response" do
    it "returns an array of strings" do
      answer = build(:checkbox_answers, response: %w[Blue Green])
      expect(answer.response).to eq(%w[Blue Green])
    end
  end

  describe "validations" do
    it "is not valid if there is no response" do
      answer = build(:checkbox_answers, response: [])
      expect(answer).not_to be_valid
    end

    context "when the step is skippable" do
      it "does not validate the presence of the response" do
        skippable_step = create(:step, :checkbox, skip_call_to_action_text: "None of the above")
        answer = build(:checkbox_answers, step: skippable_step, response: "", skipped: true)

        answer.save!

        expect(answer.persisted?).to be true
      end
    end
  end

  describe "#response=" do
    context "when the response only includes blank items" do
      it "is invalid" do
        answer = build(:checkbox_answers, response: ["", ""])
        expect(answer.valid?).to eq(false)
      end
    end

    context "when the response a mix of present and blank items" do
      it "stores the present values" do
        answer = build(:checkbox_answers, response: ["Foo", ""])
        expect(answer.response).to eq(%w[Foo])
      end
    end
  end

  describe "#update_task_counters" do
    it_behaves_like "task_counters", :checkbox, :checkbox_answers
  end
end
