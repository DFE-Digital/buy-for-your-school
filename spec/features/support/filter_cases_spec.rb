RSpec.feature "Filter cases", bullet: :skip, js: true do
  include_context "with an agent"

  let(:catering_cat) { create(:support_category, title: "Catering") }
  let(:mfd_cat) { create(:support_category, title: "MFD") }

  before do
    create_list(:support_case, 10)
    create(:support_case, category: catering_cat)
    create(:support_case, category: mfd_cat, state: :on_hold)
    create(:support_case, category: mfd_cat, state: :opened)
    create(:support_case, agent:)
    create(:support_case, state: :closed)
    visit support_root_path
  end

  describe "case filtering" do
    it "filters by category" do
      click_link "All cases"
      within "#all-cases" do
        click_button "Filter results"
        find("#filter-all-cases-form-category-field").find(:option, "Catering").select_option
        click_button "Apply filter"
        expect(all(".govuk-table__body .govuk-table__row.case-row").count).to eq(2)
        row = all(".govuk-table__body .govuk-table__row.case-row")
        expect(row[0]).to have_text "Catering"
      end
    end

    it "filters by agent" do
      click_link "All cases"
      within "#all-cases" do
        click_button "Filter results"
        find("#filter-all-cases-form-agent-field").find(:option, agent.first_name).select_option
        click_button "Apply filter"
        expect(all(".govuk-table__body .govuk-table__row .borderless").count).to eq(1)
        row = all(".govuk-table__body .govuk-table__row .borderless")
        expect(row[0]).to have_text agent.first_name
      end
    end

    it "filters by state" do
      click_link "All cases"
      within "#all-cases" do
        click_button "Filter results"
        find("#filter-all-cases-form-state-field").find(:option, "Closed").select_option
        click_button "Apply filter"
        expect(all(".govuk-table__body .govuk-table__row.case-row").count).to eq(2)
        row = all(".govuk-table__body .govuk-table__row.case-row")
        expect(row[0]).to have_text "Closed"
      end
    end
  end

  describe "case filtering and sorting" do
    it "filters by category and sorts by state" do
      click_link "All cases"
      within "#all-cases" do
        click_button "Filter results"
        find("#filter-all-cases-form-category-field").find(:option, "MFD").select_option
        click_button "Apply filter"
        click_button "Status"
        expect(all(".govuk-table__body .govuk-table__row.case-row").count).to eq(4)
        row = all(".govuk-table__body .govuk-table__row.case-row")
        expect(row[0]).to have_text "On Hold"
      end
    end
  end
end
