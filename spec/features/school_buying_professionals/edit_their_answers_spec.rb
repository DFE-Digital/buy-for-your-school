require "rails_helper"

feature "Users can edit their answers" do
  let(:user) { create(:user) }
  before { user_is_signed_in(user: user) }

  before do
    journey = answer.step.journey
    journey.update(user: user)
  end
  let(:answer) { create(:short_text_answer, response: "answer") }

  context "when the question is short_text" do
    let(:answer) { create(:short_text_answer, response: "answer") }

    scenario "The edited answer is saved" do
      visit journey_path(answer.step.journey)

      click_on(answer.step.title)

      fill_in "answer[response]", with: "email@example.com"

      click_on(I18n.t("generic.button.update"))

      click_on(answer.step.title)

      expect(find_field("answer-response-field").value).to eql("email@example.com")
    end
  end

  context "when the question is single_date" do
    let(:answer) { create(:single_date_answer, response: 1.year.ago) }

    scenario "The edited answer is saved" do
      visit journey_path(answer.step.journey)

      click_on(answer.step.title)

      fill_in "answer[response(3i)]", with: "12"
      fill_in "answer[response(2i)]", with: "8"
      fill_in "answer[response(1i)]", with: "2020"

      click_on(I18n.t("generic.button.update"))

      click_on(answer.step.title)

      expect(find_field("answer_response_3i").value).to eql("12")
      expect(find_field("answer_response_2i").value).to eql("8")
      expect(find_field("answer_response_1i").value).to eql("2020")
    end
  end

  context "when the question is checkbox_answers" do
    let(:answer) { create(:checkbox_answers, response: ["Breakfast", "Lunch", ""]) }

    scenario "The edited answer is saved" do
      visit journey_path(answer.step.journey)

      click_on(answer.step.title)

      uncheck "Breakfast"

      click_on(I18n.t("generic.button.update"))

      click_on(answer.step.title)

      expect(page).not_to have_checked_field("answer-response-breakfast-field")
      expect(page).to have_checked_field("answer-response-lunch-field")
    end
  end

  context "An error is thrown" do
    scenario "When an answer is invalid" do
      visit journey_path(answer.step.journey)

      click_on(answer.step.title)

      fill_in "answer[response]", with: ""

      click_on(I18n.t("generic.button.update"))

      expect(page).to have_content("can't be blank")
    end
  end

  context "when Contentful entry includes a 'show additional question' rule" do
    scenario "an additional question is shown" do
      start_journey_from_category_and_go_to_question(category: "show-one-additional-question.json")

      choose("School expert")
      click_on(I18n.t("generic.button.next"))

      # This question should be made visible after the previous step
      click_on("What colour is the sky?")
      choose("Red")
      click_on(I18n.t("generic.button.next"))

      # This question should be made visible after the previous step
      click_on("You should NOT be able to see this question?")
      choose("School expert")
      click_on(I18n.t("generic.button.next"))

      # Edit the first question to remove the chain of hidden questions
      click_on("What support do you have available?")
      choose("None")
      click_on(I18n.t("generic.button.update"))

      expect(page).not_to have_content("What colour is the sky? ")
      expect(page).not_to have_content("You should NOT be able to see this question?")

      # Edit the first question to add back the full chain of hidden questions
      click_on("What support do you have available?")
      choose("School expert")
      click_on(I18n.t("generic.button.update"))

      expect(page).to have_content("What colour is the sky? ")
      expect(page).to have_content("You should NOT be able to see this question?")
    end
  end
  context "when a user edits an answer" do
    scenario "the user is returned to the same place in the task list " do
      visit journey_path(answer.step.journey)

      click_on(answer.step.title)

      fill_in "answer[response]", with: "email@example.com"

      click_on(I18n.t("generic.button.update"))

      expect(page).to have_current_path(journey_url(answer.step.journey, anchor: answer.step.id))
    end
  end
end
