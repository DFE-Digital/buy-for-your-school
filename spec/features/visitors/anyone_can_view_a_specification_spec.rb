require "rails_helper"

feature "Users can view a specification" do
  context "The specification is displayed" do
    scenario "when all tasks have been completed" do
      journey = create(:journey)

      step_1 = create(:step, :radio, journey: journey)
      create(:radio_answer, step: step_1)

      step_2 = create(:step, :radio, journey: journey)
      create(:radio_answer, step: step_2)

      visit journey_path(journey)

      expect(page).to have_content(I18n.t("journey.specification.header"))
    end
  end

  context "The specification is not displayed" do
    scenario "when some tasks have been completed" do
      journey = create(:journey)

      step_1 = create(:step, :radio, journey: journey)
      create(:radio_answer, step: step_1)

      create(:step, :radio, journey: journey)

      visit journey_path(journey)

      expect(page).not_to have_content(I18n.t("journey.specification.header"))
    end

    scenario "when no tasks have been completed" do
      journey = create(:journey)

      create(:step, :radio, journey: journey)

      create(:step, :radio, journey: journey)

      visit journey_path(journey)

      expect(page).not_to have_content(I18n.t("journey.specification.header"))
    end
  end
end
