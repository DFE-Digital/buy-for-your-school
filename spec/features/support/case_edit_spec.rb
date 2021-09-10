RSpec.feature "Case Management Dashboard - edit" do
  before do
    user_is_signed_in
    visit "/support/cases/#{create(:support_case).id}/edit"
  end

  it "renders a title" do
    expect(find(".govuk-fieldset__heading", visible: true)).to have_text "Assign to caseworker"
  end

  it "renders list of agents" do
    expect(all(".govuk-radios__item", visible: true).count).to eq(1)
    expect(find(".govuk-radios__item")).to have_text "John Kendle"
  end

  it "renders the submit button" do
    expect(find_button("Assign")).to be_present
  end
end
