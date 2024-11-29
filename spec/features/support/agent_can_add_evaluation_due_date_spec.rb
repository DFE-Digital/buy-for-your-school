require "rails_helper"

describe "Edit evaluation due date", :js do
  include_context "with an agent"

  let(:support_case) { create(:support_case) }

  specify "Update evaluation due date evaluators" do
    visit edit_support_case_evaluation_due_dates_path(case_id: support_case)

    expect(page).to have_text("Set due date")
    expect(page).to have_text("When does the evaluation need to be completed by?")

    fill_in "Day", with: ""
    fill_in "Month", with: ""
    fill_in "Year", with: ""
    click_button "Continue"

    expect(page).to have_text("Enter the evaluation due date")

    fill_in "Day", with: Date.yesterday.day
    fill_in "Month", with: Date.yesterday.month
    fill_in "Year", with: Date.yesterday.year
    click_button "Continue"

    expect(page).to have_text("Evaluation due date must be in the future")
  end
end
