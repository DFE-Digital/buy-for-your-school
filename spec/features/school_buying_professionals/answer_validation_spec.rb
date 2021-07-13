require "rails_helper"

feature "Validation criteria is question specific" do
  let(:user) { create(:user) }

  before { user_is_signed_in(user: user) }

  describe "date validation" do
    before do
      start_journey_with_tasks_from_category(category: "single-date-question.json")

      within ".app-task-list" do
        click_on "Task with date validation"
      end
    end

    specify do
      expect(page).to have_content "When were you born?"
    end

    context "when date is within bounds" do
      specify do
        fill_in "answer[response(3i)]", with: "30"
        fill_in "answer[response(2i)]", with: "6"
        fill_in "answer[response(1i)]", with: "3001"

        click_on "Continue"

        expect(page).not_to have_content "Task with date validation"
        expect(page).to have_content "Are you a time traveller!"
      end
    end

    context "when date is out of bounds" do
      specify do
        fill_in "answer[response(3i)]", with: "30"
        fill_in "answer[response(2i)]", with: "6"
        fill_in "answer[response(1i)]", with: "1981"

        click_on "Continue"

        expect(page).not_to have_content "Are you a time traveller!"
        expect(page).to have_content "Task with date validation"
      end
    end
  end
end
