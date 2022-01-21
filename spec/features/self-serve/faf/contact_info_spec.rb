RSpec.feature "Faf - contact info" do
  before do
    user_is_signed_in
    visit "/procurement-support/new?step=2"
  end

  it "loads the page" do
    expect(find("span.govuk-caption-l")).to have_text "About you"
    expect(find("h1.govuk-heading-l")).to have_text "Is this your contact information?"
    expect(all("p")[1]).to have_text "If these details are not correct, you can either:"

    within("ul.govuk-list") do
      expect(all("li")[0]).to have_text "log in with the correct account, or"
      expect(all("li")[1]).to have_link "amend your DfE Sign-in account details", href: "https://test-profile.signin.education.gov.uk/edit-details", class: "govuk-link"
    end

    within("dl.govuk-summary-list") do
      expect(all("dt")[0]).to have_text "Name"
      expect(all("dd")[0]).to have_text "first_name last_name"
      expect(all("dt")[1]).to have_text "Email address"
      expect(all("dd")[1]).to have_text "test@test"
    end

    expect(page).to have_button "Yes, continue"
  end
end
