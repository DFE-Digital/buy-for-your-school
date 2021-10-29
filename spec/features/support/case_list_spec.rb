RSpec.feature "Case management dashboard" do
  include_context "with an agent"

  let(:state) { :initial }

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

  context "when my cases tab" do
    let!(:new_case) { create(:support_case, state: state, agent: agent) }

    it "shows my cases" do
      within "#my-cases" do
        pp page.source

        binding.pry
        expect(all(".govuk-table__body .govuk-table__row").count).to eq(1)
      end
    end

    xit "shows correct table headers" do
    end
  end



  it "shows new cases" do
    within "#new-cases" do
      expect(all(".govuk-table__body .govuk-table__row").count).to eq(1)
      row = all(".govuk-table__body .govuk-table__row")
      expect(row[0]).to have_text new_case.ref
    end
  end

  it "shows all cases" do
    within "#all-cases" do
      expect(all(".govuk-table__body .govuk-table__row").count).to eq(4)
    end
  end

  it "has a table with columns for org id, category name, case status and updated timestamp" do
    within "#my-cases" do
      expect(find(".govuk-table__head")).to have_text "Organisation Category Status Last updated"

      table_headers = all(".govuk-table__header")

      expect(table_headers[0]).to have_text "Case"
      expect(table_headers[1]).to have_text "Organisation"
      expect(table_headers[2]).to have_text "Category"
      expect(table_headers[3]).to have_text "Status"
      expect(table_headers[4]).to have_text "Last updated"
    end
  end
end
