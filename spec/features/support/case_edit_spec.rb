RSpec.feature "Case Management Dashboard - edit" do
  before do
    support_case = create(:support_case)

    user_is_signed_in
    visit "/support/cases/#{support_case.id}/edit"
  end

  it "displays a title" do
    expect(find("h1.govuk-fieldset__heading", visible: true)).to have_text "Assign to caseworker"
  end

  it "lists agents by name" do
    expect(all("div.govuk-radios__item", visible: true).count).to eq(1)
    expect(find("div.govuk-radios__item")).to have_text "John Kendle"
  end

  it "displays the submit button" do
    expect(find_button("Assign")).to be_present
  end
end
