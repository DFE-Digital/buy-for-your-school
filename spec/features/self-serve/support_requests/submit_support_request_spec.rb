RSpec.feature "Completed support requests" do
  let(:category) { create(:category) }
  let(:journey) { create(:journey, category: category) }

  let(:support_request) do
    create(:support_request,
           user: journey.user,
           journey: journey,
           category: category)
  end

  let(:template_collection) do
    {
      "templates" => [
        {
          "name" => "Auto-reply", # case-sensitive name of genuine template within Notify
        },
      ],
    }
  end

  before do
    # fetch template by name
    stub_request(:get,
                 "https://api.notifications.service.gov.uk/v2/templates?type=email").to_return(
                   body: template_collection.to_json,
                 )

    # send email
    stub_request(:post,
                 "https://api.notifications.service.gov.uk/v2/notifications/email").to_return(
                   body: {}.to_json,
                   status: 201,
                   headers: { "Content-Type" => "application/json" },
                 )

    user_is_signed_in(user: journey.user)
    visit "/support-requests/#{support_request.id}"
  end

  specify { expect(page).to have_current_path "/support-requests/#{support_request.id}" }

  it "does not reveal debug information" do
    expect(find_all("pre.debug_dump")).to be_empty
  end

  describe "summary" do
    it "support_requests.sections.send_your_request" do
      expect(find("h1.govuk-heading-l")).to have_text "Send your request"
    end

    it "has section headings" do
      headings = find_all("h2.govuk-heading-m")

      expect(headings[0]).to have_text "About you"
      expect(headings[1]).to have_text "About your request for support"
    end

    # support_requests.response_time
    it "confirms the expected response time" do
      expect(find("p.govuk-body")).to have_text "Once you send this request, we will review it and get in touch within 5 working days."
    end
  end

  # support_requests.buttons.send
  it "can be submitted once" do
    expect(find_button("Send request")).to be_present

    expect(support_request).not_to be_submitted
    click_button "Send request"
    expect(support_request.reload).to be_submitted

    visit "/support-requests/#{support_request.id}"
    expect(page).not_to have_button "Send request"
    expect(page).not_to have_link "Change"
  end
end
