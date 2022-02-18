RSpec.feature "Submit a 'Find a Framework' request" do
  let(:user) { create(:user, :one_supported_school) }

  let(:email) do
    {
      email_address: "test@test",
      template_id: "621a9fe9-018c-425e-ae6e-709c6718fe8d",
      reference: "000001",
      personalisation: {
        reference: "000001",
        first_name: "first_name",
        last_name: "last_name",
        email: "test@test",
        message: "please help!",
      },
    }
  end

  let(:school) do
    create(:support_organisation, urn: "100253", name: "School #1")
  end

  let(:request) do
    create(:framework_request, user: user, school_urn: "100253", group_uid: nil)
  end

  before do
    stub_request(:post, "https://api.notifications.service.gov.uk/v2/notifications/email")
      .with(body: email.to_json)
      .to_return(body: {}.to_json, status: 200, headers: {})

    user_is_signed_in(user: user)
    visit "/procurement-support/#{request.id}"
    click_on "Send request"
  end

  it "confirms where the message was sent and the response time" do
    expect(find("h1.govuk-panel__title")).to have_text "Your request for support has been sent"
    expect(find("div.govuk-panel__body")).to have_text "We have sent a confirmation email to: email@example.com"

    expect(all("h1.govuk-heading-m")[0]).to have_text "What happens next"
    expect(all("p.govuk-body")[0]).to have_text "The Get help buying for schools team will be in touch within 2 working days."
    expect(all("p.govuk-body")[1]).to have_text "Please check to make sure you receive the email confirmation within the next 10 minutes. Check your junk folder if you do not see it."
    expect(all("p.govuk-body")[2]).to have_text "You will need to submit the request again if you do not receive an email from us because this is how we will be contacting you."

    expect(all("h1.govuk-heading-m")[1]).to have_text "What you can do next"
    within("ul.govuk-list") do
      expect(page).to have_link "read buying procedures and procurement law for schools", href: "https://www.gov.uk/guidance/buying-procedures-and-procurement-law-for-schools", class: "govuk-link"
      expect(page).to have_link "read guides about goods and services", href: "https://www.gov.uk/guidance/buying-for-schools", class: "govuk-link"
    end
  end
end
