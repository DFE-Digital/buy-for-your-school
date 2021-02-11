require "rails_helper"

feature "Users can edit their answers" do
  before do
    journey = answer.step.journey
    journey.update(section_groups: [
      {
        "order" => 0,
        "title" => "Section A",
        "steps" => [
          {
            "contentful_id" => answer.step.contentful_id,
            "order" => 0
          }
        ]
      }
    ])
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
    let(:answer) { create(:checkbox_answers, response: ["breakfast", "lunch", ""]) }

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
      start_journey_from_category_and_go_to_question(category: "show-additional-question.json")

      choose("School expert")

      click_on(I18n.t("generic.button.next"))

      expect(page).to have_content("What support do you have available?")
    end
  end
end
