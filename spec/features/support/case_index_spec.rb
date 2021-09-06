RSpec.feature "Case Management Dashboard - index" do
  before do
    user_is_signed_in
    visit "/support/cases"
  end

  it "renders 3 tabs" do
    expect(all(".govuk-tabs__list-item", visible: true).count).to eq(3)
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
    expect(find("#my-cases .govuk-table__head")).to have_text "Organisation Category Status Last updated"
  end

  context "when clicking on the 'New cases' tab" do
    before { click_link "New cases" }

    it "only renders the 'New Cases' tab" do
      expect(find("#new-cases .govuk-heading-l", visible: true)).to have_text "New cases"
    end
  end
end
