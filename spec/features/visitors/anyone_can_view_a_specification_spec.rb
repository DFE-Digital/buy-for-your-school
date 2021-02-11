require "rails_helper"

feature "Users can view a specification" do
  context "The specification is displayed" do
    scenario "when at least one task has been completed" do
      journey = create(:journey)

      step_1 = create(:step, :radio, journey: journey)
      create(:radio_answer, step: step_1)



      visit journey_path(journey)

      expect(page).to have_content(I18n.t("journey.specification.header"))
    end
  end

  context "An error is displayed" do
    scenario "when an incomplete specification is downloaded" do
      journey = create(:journey)

      step_1 = create(:step, :radio, journey: journey)
      create(:radio_answer, step: step_1)

      create(:step, :radio, journey: journey)

      visit journey_path(journey)

      expect(page).not_to have_content(I18n.t("journey.specification.header"))
    end

    scenario "when an incomplete specification is viewed" do
      journey = create(:journey)

      create(:step, :radio, journey: journey)

      create(:step, :radio, journey: journey)

      visit journey_path(journey)

      expect(page).not_to have_content(I18n.t("journey.specification.header"))
    end
  end
end
