RSpec.feature "Users can edit their answers" do
  let(:user) { create(:user) }
  let(:answer) { create(:short_text_answer, response: "answer") }
  let(:title) { answer.step.task.title }
  let(:journey) { answer.step.journey }

  before do
    user_is_signed_in(user: user)

    journey.update!(user: user)
  end

  context "when the question_types is short_text" do
    let(:answer) { create(:short_text_answer, response: "answer") }

    scenario "The edited answer is saved" do
      visit_journey
      click_on title
      fill_in "answer[response]", with: "email@example.com"
      click_update
      click_on title
      expect(find_field("answer-response-field").value).to eql "email@example.com"
    end
  end

  context "when the question_types is single_date" do
    let(:answer) { create(:single_date_answer, response: 1.year.ago) }

    scenario "The edited answer is saved" do
      visit_journey
      click_on title
      fill_in "answer[response(3i)]", with: "12"
      fill_in "answer[response(2i)]", with: "8"
      fill_in "answer[response(1i)]", with: "2020"
      click_update
      click_on title
      expect(find_field("answer_response_3i").value).to eql "12"
      expect(find_field("answer_response_2i").value).to eql "8"
      expect(find_field("answer_response_1i").value).to eql "2020"
    end
  end

  context "when the question_types is checkbox_answers" do
    let(:answer) { create(:checkbox_answers, response: ["Breakfast", "Lunch", ""]) }

    scenario "The edited answer is saved" do
      visit_journey
      click_on title
      uncheck "Breakfast"
      click_update
      click_on title
      expect(page).not_to have_checked_field "answer-response-breakfast-field"
      expect(page).to have_checked_field "answer-response-lunch-field"
    end
  end

  context "when an error is thrown" do
    scenario "When an answer is invalid" do
      visit_journey
      click_on title
      fill_in "answer[response]", with: ""
      click_update
      expect(page).to have_content "can't be blank"
    end
  end

  context "when a user edits an answer" do
    scenario "the user is returned to the same place in the task list " do
      visit_journey
      click_on title
      fill_in "answer[response]", with: "email@example.com"
      click_update
      expect(page).to have_current_path journey_url(journey, anchor: answer.step.id)
    end

    scenario "an action is recorded" do
      visit_journey
      click_on title
      fill_in "answer[response]", with: "email@example.com"
      click_update

      logged_event = ActivityLogItem.where(action: "update_answer").first

      expect(logged_event.journey_id).to eq journey.id
      expect(logged_event.user_id).to eq user.id
      expect(logged_event.contentful_category_id).to eq "12345678"
      expect(logged_event.contentful_section_id).to eq answer.step.task.section.contentful_id
      expect(logged_event.contentful_task_id).to eq answer.step.task.contentful_id
      expect(logged_event.contentful_step_id).to eq answer.step.contentful_id
      expect(logged_event.data["success"]).to be true
    end
  end
end
