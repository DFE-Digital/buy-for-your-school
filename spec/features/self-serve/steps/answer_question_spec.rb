#
# Check that questions can be answered with valid input
#
# TODO: add missing question types
RSpec.feature "Answering questions" do
  let(:user) { create(:user) }
  let(:title) { answer.step.task.title }
  let(:journey) { answer.step.journey }

  before do
    user_is_signed_in(user: user)
    journey.update!(user: user)
    visit_journey
    click_on title
  end

  context "when the only question is answered" do
    let(:answer) { create(:short_text_answer, response: "answer") }

    scenario "the user is returned to the same position on the journey page" do
      fill_in "answer[response]", with: "email@example.com"
      click_update

      expect(find("strong.app-task-list__tag")).to have_text "Completed"
      expect(page.current_url).to eql "http://www.example.com:3000/journeys/#{journey.id}##{answer.step.id}"
    end
  end

  context "when the question is a short text" do
    let(:answer) { create(:short_text_answer, response: "answer") }

    context "and the answer is omitted" do
      it "renders a validation error" do
        fill_in "answer[response]", with: " "
        click_update

        expect(find("span.govuk-error-message")).to have_text "can't be blank"

        fill_in "answer[response]", with: ""
        click_update

        expect(find("span.govuk-error-message")).to have_text "can't be blank"
      end
    end

    context "and the question is answered" do
      scenario "the answer is saved" do
        fill_in "answer[response]", with: "email@example.com"
        click_update
        click_on title

        expect(find_field("answer-response-field").value).to eql "email@example.com"
      end
    end
  end

  context "when the question is a date" do
    let(:answer) { create(:single_date_answer, response: 1.year.ago) }

    context "and the answer is not the correct format" do
      it "renders a validation error" do
        fill_in "answer[response(3i)]", with: "TEXT"
        click_update

        expect(find("span.govuk-error-message")).to have_text "Provide a real date for this answer"
      end
    end

    context "and the question is answered" do
      scenario "the answer is saved" do
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
  end

  context "when the question is a checkbox" do
    let(:answer) { create(:checkbox_answers, response: ["Breakfast", "Lunch", ""]) }

    context "and the answer is omitted" do
      it "renders a validation error" do
        uncheck "Lunch"
        uncheck "Breakfast"
        click_update

        expect(find("span.govuk-error-message")).to have_text "can't be blank"
      end
    end

    context "and the question is answered" do
      scenario "the answer is saved" do
        uncheck "Breakfast"
        click_update
        click_on title

        expect(page).not_to have_checked_field "answer-response-breakfast-field"
        expect(page).to have_checked_field "answer-response-lunch-field"
      end
    end
  end
end
