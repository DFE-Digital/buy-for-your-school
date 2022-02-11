RSpec.feature "Case management dashboard", bullet: :skip do
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
    let!(:new_case) { create(:support_case, agent: agent) }

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
        expect(table_headers[2]).to have_text "Category"
        expect(table_headers[3]).to have_text "Status"
        expect(table_headers[4]).to have_text "Last updated"
      end
    end

    describe "pagination" do
      before do
        create_list(:support_case, 40, agent: agent)
        visit "/support/cases#my-cases"
      end

      it "shows the pagination info" do
        within "#my-cases" do
          expect(all(".govuk-table__body .govuk-table__row").count).to eq(10)
          expect(page).to have_text "Showing 1 to 10 of 41 results"
        end
      end

      it "changes to a different page when a new page is clicked" do
        within "#my-cases" do
          find("a", text: "Next").click
          expect(page).to have_text "Showing 11 to 20 of 41 results"
        end
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
        expect(table_headers[2]).to have_text "Category"
        expect(table_headers[3]).to have_text "Status"
        expect(table_headers[4]).to have_text "Date received"
      end
    end

    describe "pagination" do
      before do
        create_list(:support_case, 20)
        visit "/support/cases#new-cases"
      end

      it "shows the pagination info" do
        within "#new-cases" do
          expect(all(".govuk-table__body .govuk-table__row").count).to eq(10)
          expect(page).to have_text "Showing 1 to 10 of 23 results"
        end
      end

      it "changes to a different page when a new page is clicked" do
        within "#new-cases" do
          find("a", text: "Next").click
          expect(page).to have_text "Showing 11 to 20 of 23 results"
        end
      end
    end
  end

  context "when all cases tab" do
    before do
      create(:support_case, state: :resolved)
      visit "/support/cases"
    end

    it "shows all cases" do
      within "#all-cases" do
        expect(all(".govuk-table__body .govuk-table__row").count).to eq(4)
      end
    end

    it "shows correct table headers" do
      within "#all-cases" do
        table_headers = all(".govuk-table__header")
        expect(table_headers[0]).to have_text "Case"
        expect(table_headers[1]).to have_text "Organisation"
        expect(table_headers[2]).to have_text "Category"
        expect(table_headers[3]).to have_text "Status"
        expect(table_headers[4]).to have_text "Assigned to"
        expect(table_headers[5]).to have_text "Last updated"
      end
    end

    describe "pagination" do
      before do
        create_list(:support_case, 29)
        visit "/support/cases#all-cases"
      end

      it "shows the pagination info" do
        within "#all-cases" do
          expect(all(".govuk-table__body .govuk-table__row").count).to eq(10)
          expect(page).to have_text "Showing 1 to 10 of 33 results"
        end
      end

      it "changes to a different page when a new page is clicked" do
        within "#all-cases" do
          find("a", text: "Next").click
          expect(page).to have_text "Showing 11 to 20 of 33 results"
        end
      end
    end
  end
end
