RSpec.feature "Case management dashboard" do
  include_context "with an agent"

  before do
    create_list(:support_case, 3)
    visit support_root_path
  end

  it "is signed in as correct agent" do
    within "header.govuk-header" do
      expect(find("#userInfo")).to have_text "Signed in as Procurement Specialist"
    end
  end

  it "defaults to the 'my cases' tab" do
    expect(find("#my-cases")).not_to have_css ".govuk-tabs__panel--hidden"
  end

  context "when a case has actions required" do
    before do
      create(:support_case, :action_required, ref: "009999")
      visit "/support/cases"
    end

    it "displays the action flag" do
      within "#all-cases .case-row", text: "009999" do
        expect(page).to have_css(".case-action-required-icon")
      end
    end
  end

  context "when my cases tab" do
    let!(:new_case) { create(:support_case, agent:) }

    before do
      create(:support_case, state: :resolved)
      visit "/support/cases"
    end

    it "shows my cases" do
      within "#my-cases" do
        expect(all(".govuk-table__body .govuk-table__row.tower-top-row").count).to eq(1)
        row = all(".govuk-table__body .govuk-table__row.tower-top-row")
        expect(row[0]).to have_text new_case.ref
      end
    end

    it "does not show resolved cases" do
      within "#my-cases" do
        within "tbody.govuk-table__body" do
          expect(page).not_to have_text("Resolved")
        end
      end
    end

    it "shows correct table headers" do
      within "#my-cases" do
        table_headers = all(".govuk-table__header")
        confirm_header_order(table_headers, ["", "Case", "Level", "Organisation", "Category", "Status", "Updated", ""])
      end
    end

    it "displays a link to view all the agent's resolved cases" do
      expect(page).to have_link("View all my resolved cases", href: support_cases_path(anchor: "my-cases", filter_my_cases_form: { state: "resolved" }))
    end
  end

  context "when new cases tab" do
    before do
      create(:support_case, state: :closed)
      visit "/support/cases"
    end

    it "shows new cases" do
      within "#new-cases" do
        expect(all(".govuk-table__body .govuk-table__row.borderless").count).to eq(3)
      end
    end

    it "shows correct table headers" do
      within "#new-cases" do
        table_headers = all(".govuk-table__header")
        confirm_header_order(table_headers, ["", "Case", "Organisation", "Category", "Status", "Received"])
      end
    end
  end

  context "when triage cases tab" do
    before do
      create(:support_case, state: :closed)
      visit "/support/cases"
    end

    it "shows triage cases" do
      within "#triage-cases" do
        expect(all(".govuk-table__body .govuk-table__row.case-row").count).to eq(6)
      end
    end
  end

  context "when all cases tab" do
    before do
      create(:support_case, state: :resolved)
      create(:support_case, state: :closed)
      visit "/support/cases"
    end

    it "shows all valid cases" do
      within "#all-cases" do
        expect(all(".govuk-table__body .govuk-table__row.case-row").count).to eq(8)
      end
    end

    it "does not show closed cases" do
      within "#all-cases" do
        within "tbody.govuk-table__body" do
          expect(page).not_to have_text("Closed")
        end
      end
    end

    it "shows resolved cases" do
      within "#all-cases" do
        within "tbody.govuk-table__body" do
          expect(page).to have_text("Resolved")
        end
      end
    end

    it "shows correct table headers" do
      within "#all-cases" do
        table_headers = all(".govuk-table__header")
        confirm_header_order(table_headers, ["", "Case", "Level", "Organisation", "Category", "Status", "Updated"])
      end
    end
  end

private

  def confirm_header_order(headers, expected)
    expected.each_with_index do |header, index|
      expect(headers[index]).to have_text header
    end
  end
end
