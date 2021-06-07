require "rails_helper"

feature "Back link works after failed form validations" do
  let(:user) { create(:user) }
  before { user_is_signed_in(user: user) }

  it "clears the validation error rather than raise a routing error" do
    start_journey_with_tasks_from_category(category: "section-with-multiple-tasks.json")

    within ".app-task-list" do
      click_on "Task containing every type of step"
    end

    # form validation errors because not answered
    click_on "Continue"

    # would raise routing error without routes guard clause
    click_on "Back"

    expect(page).to have_content "Describe what you need"
  end

end
