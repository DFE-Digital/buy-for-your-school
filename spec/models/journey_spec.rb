require "rails_helper"

RSpec.describe Journey, type: :model do
  it { should have_many(:steps) }

  describe "validations" do
    it { is_expected.to validate_presence_of(:liquid_template) }
  end

  it "captures the category" do
    journey = build(:journey, :catering)
    expect(journey.category).to eql("catering")
  end

  describe "all_steps_completed?" do
    context "when all steps have been completed" do
      it "returns true" do
        journey = create(:journey)

        step_1 = create(:step, :radio, journey: journey)
        create(:radio_answer, step: step_1)

        step_2 = create(:step, :radio, journey: journey)
        create(:radio_answer, step: step_2)

        expect(journey.all_steps_completed?).to be true
      end
    end

    context "when no steps have been completed" do
      it "returns false " do
        journey = create(:journey)

        create_list(:step, 2, :radio, journey: journey)

        expect(journey.all_steps_completed?).to be false
      end
    end

    context "when only some steps have been completed" do
      it "returns false" do
        journey = create(:journey)

        step_1 = create(:step, :radio, journey: journey)
        create(:radio_answer, step: step_1)

        create(:step, :radio, journey: journey)

        expect(journey.all_steps_completed?).to be false
      end
    end

    context "when there are uncompleted hidden steps" do
      it "ignores them and returns true" do
        journey = create(:journey)

        step_1 = create(:step, :radio, journey: journey)
        create(:radio_answer, step: step_1)

        _hidden_step_without_an_answer = create(:step, :radio, journey: journey, hidden: true)

        expect(journey.all_steps_completed?).to be true
      end
    end
  end
end
