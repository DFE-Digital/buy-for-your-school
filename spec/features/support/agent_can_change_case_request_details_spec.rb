require "rails_helper"

describe "Agent can change case request details", js: true do
  include_context "with an agent"

  let(:support_case) { create(:support_case, category: gas_category) }

  before do
    define_basic_categories
    define_basic_queries

    click_button "Agent Login"
    visit support_case_path(support_case)
    click_link "Case details"
    within "h3", text: "Request - change" do
      click_link "change"
    end
  end

  describe "Agent changes from procurement category to query" do
    before do
      choose "Non-procurement"
      select "Other", from: "select_request_details_query_id"
      find("#request_details_other_query_text").set("Other Query Details")
      fill_in "Description of query", with: "My request description"
      click_button "Save and continue"
    end

    it "allows the user to check their answers" do
      within ".govuk-summary-list__row", text: "Query" do
        expect(page).to have_content("Other - Other Query Details")
      end
      within ".govuk-summary-list__row", text: "Type" do
        expect(page).to have_content("Non-procurement")
      end
      within ".govuk-summary-list__row", text: "Description of query" do
        expect(page).to have_content("My request description")
      end
    end

    describe "submitting results" do
      it "shows the new category in case details" do
        click_button "Submit"

        within ".govuk-summary-list__row", text: "Query" do
          expect(page).to have_content("Other - Other Query Details")
        end
        within ".govuk-summary-list__row", text: "Description of query" do
          expect(page).to have_content("My request description")
        end
      end
    end
  end
end
