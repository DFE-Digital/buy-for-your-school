RSpec.feature "Case management dashboard" do
  include_context "with an agent"

  before do
    create_list(:support_case, 3)
    click_button "Agent Login"
    # visit "/support/cases"
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

    it "displays the status 'Action'" do
      within "#all-cases .case-row", text: "009999" do
        expect(page).to have_css(".case-status", text: "Action")
      end
    end
  end

  context "when my cases tab" do
    let!(:new_case) { create(:support_case, agent:) }

    before do
      visit "/support/cases"
    end

    it "shows my cases" do
      within "#my-cases" do
        expect(all(".govuk-table__body .govuk-table__row").count).to eq(1)
        row = all(".govuk-table__body .govuk-table__row")
        expect(row[0]).to have_text new_case.ref
      end
    end

    it "shows correct table headers" do
      within "#my-cases" do
        table_headers = all(".govuk-table__header")
        expect(table_headers[0]).to have_text "Case"
        expect(table_headers[1]).to have_text "Organisation"
        expect(table_headers[2]).to have_text "Sub-category"
        expect(table_headers[3]).to have_text "Status"
        expect(table_headers[4]).to have_text "Last updated"
      end
    end
  end

  context "when new cases tab" do
    before do
      create(:support_case, state: :closed)
      visit "/support/cases"
    end

    it "shows new cases" do
      within "#new-cases" do
        expect(all(".govuk-table__body .govuk-table__row").count).to eq(3)
      end
    end

    it "shows correct table headers" do
      within "#new-cases" do
        table_headers = all(".govuk-table__header")
        expect(table_headers[0]).to have_text "Case"
        expect(table_headers[1]).to have_text "Organisation"
        expect(table_headers[2]).to have_text "Sub-category"
        expect(table_headers[3]).to have_text "Status"
        expect(table_headers[4]).to have_text "Date received"
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
        expect(all(".govuk-table__body .govuk-table__row").count).to eq(4)
      end
    end

    it "does not show closed cases" do
      within "#all-cases" do
        within "tbody.govuk-table__body" do
          expect(page).not_to have_text("Closed")
        end
      end
    end

    it "shows correct table headers" do
      within "#all-cases" do
        table_headers = all(".govuk-table__header")
        expect(table_headers[0]).to have_text "Case"
        expect(table_headers[1]).to have_text "Organisation"
        expect(table_headers[2]).to have_text "Sub-category"
        expect(table_headers[3]).to have_text "Status"
        expect(table_headers[4]).to have_text "Assigned to"
        expect(table_headers[5]).to have_text "Last updated"
      end
    end
  end
end
