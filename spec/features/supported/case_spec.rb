RSpec.feature "Supported Case View" do
  before do
    user_is_signed_in
    visit "/support/cases/1"
  end

  it "shows tabs" do
    expect(all(".govuk-tabs__list-item").count).to eq(3)
  end

  it "shows visible tabs" do
    all(".govuk-tabs__list-item").each do |tab|
      expect(tab).to be_visible
    end
  end

  it "shows School details tab" do
    expect(find(".govuk-tabs__list-item--selected")).to have_text "School details"
  end

  it "shows School details" do
    expect(find("#school-details .govuk-summary-list")).to be_visible
  end

  it "shows correct content" do
    expect(find("#school-details .govuk-summary-list")).to have_text "Contact name"
  end
end
