RSpec.feature "Supported Cases View" do
  before do
    user_is_signed_in
    visit "/support/cases"
  end

  it "shows tabs" do
    expect(all(".govuk-tabs__list-item").count).to eq(3)
  end

  it "shows visible tabs" do
    all(".govuk-tabs__list-item").each do |tab|
      expect(tab).to be_visible
    end
  end

  it "shows My cases tab" do
    expect(find(".govuk-tabs__list-item--selected")).to have_text "My cases"
  end

  it "shows cases" do
    expect(find("#my-cases .govuk-table")).to be_visible
  end

  it "shows correct columns" do
    expect(find("#my-cases .govuk-table__head")).to have_text "Organisation Category Status Last updated"
  end
end
