require "rails_helper"

describe "Agent can categorise framework", js: true do
  include_context "with a framework evaluation agent"

  let(:framework) { create(:frameworks_framework) }

  before { define_basic_categories }

  it "saves the categories" do
    visit frameworks_framework_path(framework)
    within ".govuk-summary-list__row", text: "Categories" do
      click_on "Change"
    end
    check "Laptops"
    check "Electricity"
    click_on "Save changes"

    expect(page).to have_summary("Categories", "Laptops, Electricity")
    expect(page).to have_content('Category "Laptops" added')
    expect(page).to have_content('Category "Electricity" added')
  end
end
