require "rails_helper"

describe "Admin can debug category detection algorithm" do
  include_context "with an agent"

  let(:query) { "I need a new Gas tariff" }
  let(:query_results) do
    [
      Support::CategoryDetection.new(category_id: 1, tower: "Energy", category: "Gas", similarity: 1.0, matching_words: "gas, tariff"),
      Support::CategoryDetection.new(category_id: 2, tower: "Energy", category: "Electricity", similarity: 0.5, matching_words: "tariff"),
    ]
  end

  before { allow(Support::CategoryDetection).to receive(:results_for).with(query, anything).and_return(query_results) }

  scenario "Admin runs category detection algorithm and sees results" do
    Given :"I am an admin"
    When :"I enter query into the category detection algorithm"
    Then :"I see the results for the query"
  end

protected

  def_Given :"I am an admin" do
    user.update!(admin: true)
  end

  def_When :"I enter query into the category detection algorithm" do
    click_button "Agent Login"
    visit support_management_path
    click_on "Category Detection"
    fill_in "Manually detect categories", with: query
    click_on "Detect category"
  end

  def_Then :"I see the results for the query" do
    result_rows = all("#category-results tbody tr")
    within(result_rows.first) { expect(page).to have_content("Gas") }
    within(result_rows.last)  { expect(page).to have_content("Electricity") }
  end
end
