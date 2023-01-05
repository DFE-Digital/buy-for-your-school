RSpec.feature "Submitting a 'Find a Framework' request" do
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
    create(:framework_request, user:, org_id: "100253", group: false)
  end

  before do
    stub_request(:post, "https://api.notifications.service.gov.uk/v2/notifications/email")
      .with(body: email.to_json)
      .to_return(body: {}.to_json, status: 200, headers: {})

    create(:user_journey, framework_request: request, case: nil)

    user_is_signed_in(user:)
    visit "/procurement-support/#{request.id}"
    click_on "Send request"
  end

  it "confirms where the message was sent and the response time" do
    expect(page).to have_content "Your request for support has been sent"
    expect(page).to have_content "We have sent a confirmation email to: email@example.com"

    expect(page).to have_content "What happens next"
    expect(page).to have_content "The Get help buying for schools team will be in touch within 2 working days."
    expect(page).to have_content "Please check to make sure you receive the email confirmation within the next 10 minutes. Check your junk folder if you do not see it."
    expect(page).to have_content "You will need to submit the request again if you do not receive an email from us because this is how we will be contacting you."

    expect(page).to have_content "What you can do next"
    expect(page).to have_link "read buying procedures and procurement law for schools", href: "https://www.gov.uk/guidance/buying-procedures-and-procurement-law-for-schools", class: "govuk-link"
    expect(page).to have_link "read guides about goods and services", href: "https://www.gov.uk/guidance/buying-for-schools", class: "govuk-link"
  end
end
