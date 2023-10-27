require "rails_helper"

describe "Agent can change case summary", js: true do
  include_context "with an agent"

  let(:support_case) { create(:support_case, support_level: :L1, value: nil, source: "nw_hub", project: "test project", category: gas_category, procurement_stage: need_stage) }

  before do
    define_basic_categories
    define_basic_queries
    define_basic_procurement_stages

    visit support_case_path(support_case)
    click_on "Case details"
    within "h3", text: "Case summary - change" do
      click_link "change"
    end
  end

  context "when changing the support level, procurement stage, case value, case project, and next key date" do
    before do
      choose "4 - DfE buying through a framework"
      select "Tender preparation", from: "Procurement stage"
      fill_in "Case value or estimated contract value (optional)", with: "123.32"
      select "Please select", from: "Case project"
      fill_in "Day", with: "10"
      fill_in "Month", with: "08"
      fill_in "Year", with: "2023"
      fill_in "Description of next key date", with: "Key event"
      click_button "Continue"
      click_button "Save"
    end

    it "persists the changes" do
      expect(support_case.reload.support_level).to eq("L4")
      expect(support_case.reload.procurement_stage.key).to eq("tender_preparation")
      expect(support_case.reload.value).to eq(123.32)
      expect(support_case.reload.source).to eq("nw_hub")
      expect(support_case.reload.project).to eq(nil)
      expect(support_case.reload.next_key_date).to eq(Date.parse("2023-08-10"))
      expect(support_case.reload.next_key_date_description).to eq("Key event")
    end
  end

  describe "Agent changes from procurement category to query" do
    before do
      choose "Non-procurement"
      select "Other", from: "select_request_details_query_id"
      find("#request_details_other_query_text").set("Other Query Details")
      click_continue
    end

    it "allows the user to check their answers" do
      within ".govuk-summary-list__row", text: "Query" do
        expect(page).to have_content("Other - Other Query Details")
      end
    end

    describe "submitting results" do
      it "shows the new category in case details" do
        click_button "Save"

        within ".govuk-summary-list__row", text: "Query" do
          expect(page).to have_content("Other - Other Query Details")
        end
      end
    end
  end

  describe "Agent can add a new project" do
    before do
      select "Add new project", from: "Case project"
      find("#new_project_text").set("brand new project")
      click_continue
    end

    it "allows the user to check their answers" do
      within ".govuk-summary-list__row", text: "Project" do
        expect(page).to have_content("brand new project")
      end
    end

    describe "submitting results" do
      it "shows the new project in case details" do
        click_button "Save"

        within ".govuk-summary-list__row", text: "Project" do
          expect(page).to have_content("brand new project")
        end
      end
    end
  end
end
