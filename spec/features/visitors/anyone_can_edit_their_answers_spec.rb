require "rails_helper"

feature "Users can edit their answers" do
  let(:answer) { create(:short_text_answer, response: "answer") }

  scenario "The journey summary page displays a change link" do
    visit journey_path(answer.step.journey)

    expect(page).to have_content("answer")
    expect(page).to have_content("Change")
  end

  context "when the question is short_text" do
    let(:answer) { create(:short_text_answer, response: "answer") }

    scenario "The edited answer is saved" do
      visit journey_path(answer.step.journey)

      click_on(I18n.t("generic.button.change_answer"))

      fill_in "answer[response]", with: "email@example.com"

      click_on(I18n.t("generic.button.update"))

      expect(page).to have_content("email@example.com")
    end
  end

  context "when the question is single_date" do
    let(:answer) { create(:single_date_answer, response: 1.year.ago) }

    scenario "The edited answer is saved" do
      visit journey_path(answer.step.journey)

      click_on(I18n.t("generic.button.change_answer"))

      fill_in "answer[response(3i)]", with: "12"
      fill_in "answer[response(2i)]", with: "8"
      fill_in "answer[response(1i)]", with: "2020"

      click_on(I18n.t("generic.button.update"))

      expect(page).to have_content("12 Aug 2020")
    end
  end

  context "when the question is checkbox_answers" do
    let(:answer) { create(:checkbox_answers, response: ["breakfast", "lunch", ""]) }

    scenario "The edited answer is saved" do
      visit journey_path(answer.step.journey)

      click_on(I18n.t("generic.button.change_answer"))

      uncheck "Breakfast"

      click_on(I18n.t("generic.button.update"))

      expect(page).not_to have_content("Breakfast")
      expect(page).to have_content("Lunch")
    end
  end

  context "An error is thrown" do
    scenario "When an answer is invalid" do
      visit journey_path(answer.step.journey)

      click_on(I18n.t("generic.button.change_answer"))

      fill_in "answer[response]", with: ""

      click_on(I18n.t("generic.button.update"))

      expect(page).to have_content("can't be blank")
    end
  end
end
