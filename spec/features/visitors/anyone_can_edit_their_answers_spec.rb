require "rails_helper"

feature "Users can edit their answers" do
  let(:answer) { create(:short_text_answer, response: "answer") }
  scenario "The journey summary page displays a change link" do
    visit journey_path(answer.step.journey)

    expect(page).to have_content("answer")
    expect(page).to have_content("Change")
  end

  scenario "The edited answer is saved" do
    visit journey_path(answer.step.journey)

    click_on(I18n.t("generic.button.change_answer"))

    fill_in "answer[response]", with: "email@example.com"

    click_on(I18n.t("generic.button.update"))

    expect(page).to have_content("email@example.com")
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
