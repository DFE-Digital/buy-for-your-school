require "rails_helper"

describe "Agent can categorise framework" do
  include_context "with a framework evaluation agent"

  let(:framework) { create(:frameworks_framework) }

  before { define_basic_categories }

  it "assigns the categories" do
    visit edit_frameworks_framework_categorisations_path(framework)
    check "Laptops"
    check "Electricity"
    click_on "Save changes"

    within ".govuk-summary-card", text: "Basic Details" do
      expect(page).to have_content("Laptops, Electricity")
    end

    within "#framework-activity" do
      expect(page).to have_content("Category Laptops added")
      expect(page).to have_content("Category Electricity added")
    end
  end
end
