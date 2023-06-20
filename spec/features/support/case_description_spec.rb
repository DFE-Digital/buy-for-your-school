RSpec.describe "Case problem description" do
  include_context "with an agent"

  context "when a case is created via 'create a case'" do
    let(:support_case) { create(:support_case, category: gas_category) }

    before do
      define_basic_categories
      visit "/support/cases/#{support_case.id}"
    end

    it "allows a user to update the problem description" do
      within("div#case-details") do
        within "h3", text: "Request - change" do
          click_on "change"
        end
      end

      fill_in "Description of query", with: "updated query"
      click_button "Save and continue"
      click_button "Submit"

      within("div#case-details") do
        within ".govuk-summary-list__row", text: "Description of query" do
          expect(page).to have_content("updated query")
        end
      end
    end
  end
end
