RSpec.feature "Case Management Dashboard - show" do
  before do
    user_is_signed_in
    visit "/support/cases/#{create(:support_case).id}"
  end

  it "has 3 visible tabs" do
    expect(all(".govuk-tabs__list-item", visible: true).count).to eq(3)
  end

  it "defaults to the 'School details' tab" do
    expect(find(".govuk-tabs__list-item--selected")).to have_text "School details"
  end

  it "shows School details section" do
    within "#school-details" do
      expect(find(".govuk-summary-list")).to be_visible
    end
  end

  it "School details section contain contact name" do
    within "#school-details" do
      expect(find(".govuk-summary-list")).to have_text "Contact name"
    end
  end
end
