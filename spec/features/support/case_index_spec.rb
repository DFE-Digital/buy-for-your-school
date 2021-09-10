RSpec.feature "Case Management Dashboard - index" do
  before do
    create(:support_case)

    user_is_signed_in
    visit "/support/cases"
  end

  it "renders 3 tabs" do
    expect(all("li.govuk-tabs__list-item", visible: true).count).to eq(3)
  end

  it "defaults to the 'My Cases' tab" do
    expect(find("#my-cases .govuk-heading-l", visible: true)).to have_text "My cases"
  end

  it "renders cases" do
    expect(find("#my-cases .govuk-table")).to be_visible

    # TODO: Change ".all.count" with ".count"
    expect(all("#my-cases .govuk-table__row").count).to eq(Support::Case.all.count + 1)
  end

  it "renders a table with columns for org id, category name, case status and updated timestamp" do
    within "#my-cases" do
      expect(find(".govuk-table__head")).to have_text "Organisation Category Status Last updated"

      table_headers = all(".govuk-table__header")

      expect(table_headers[0]).to have_text "Organisation"
      expect(table_headers[1]).to have_text "Category"
      expect(table_headers[2]).to have_text "Status"
      expect(table_headers[3]).to have_text "Last updated"
    end
  end
end
