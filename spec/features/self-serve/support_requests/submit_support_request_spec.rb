RSpec.feature "Submitting a 'Digital Support' request" do
  before do
    create(:support_category, slug: "slug", title: "Slug")
    create(:support_organisation, urn: "urn-type-1", name: "Specialist School for Testing")

    stub_request(:post, "https://api.notifications.service.gov.uk/v2/notifications/email")
      .with(body: email.to_json)
      .to_return(body: {}.to_json, status: 200, headers: {})

    user_is_signed_in(user: journey.user)
    visit "/support-requests/#{support_request.id}"
  end

  let(:category) { create(:category, slug: "slug") }
  let(:journey) { create(:journey, category: category) }

  let(:support_request) do
    create(:support_request,
           user: journey.user,
           journey: journey,
           category: category,
           school_urn: "urn-type-1")
  end

  let(:email) do
    {
      email_address: "test@test",
      template_id: "acb20822-a5eb-43a6-8607-b9c8e25759b4",
      reference: "000001",
      personalisation: {
        reference: "000001",
        first_name: "first_name",
        last_name: "last_name",
        email: "test@test",
        message: "Support request message from a School Buying Professional",
        category: "slug",
      },
    }
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
      expect(find("p.govuk-body")).to have_text "Once you send this request, we will review it and get in touch within 2 working days."
    end
  end

  describe "clicking the submission button" do
    # support_requests.buttons.send
    before do
      click_button "Send request"
    end

    it "submits the request" do
      expect(support_request.reload).to be_submitted
      # support_request_submissions.confirmation.header
      expect(find("h1.govuk-panel__title")).to have_text "Your request for support has been sent"
    end

    it "can be submitted only once" do
      visit "/support-requests/#{support_request.id}"
      expect(page).not_to have_button "Send request"
      expect(page).not_to have_link "Change"
      # support_request_submissions.confirmation.header
      expect(find("h1.govuk-panel__title")).to have_text "Your request for support has been sent"
    end
  end

  describe "confirmation" do
    before do
      click_button "Send request"
    end

    specify do
      expect(page).to have_current_path "/support-request-submissions/#{support_request.id}"
    end

    it "confirms the email was sent" do
      # support_request_submissions.confirmation.header
      expect(find("h1.govuk-panel__title")).to have_text "Your request for support has been sent"
      # support_request_submissions.sub_header.confirmation
      expect(find("div.govuk-panel__body")).to have_text "We have sent a confirmation to: test@test"
    end

    it "links to the dashboard" do
      expect(page).to have_link "start a new specification", href: "/dashboard"
    end

    it "links to further information" do
      within "ul.govuk-list--bullet" do
        expect(page).to have_link "read buying procedures and procurement law for schools", href: "https://www.gov.uk/guidance/buying-procedures-and-procurement-law-for-schools"
        expect(page).to have_link "read guides about goods and services", href: "https://www.gov.uk/guidance/buying-for-schools"
      end
    end

    context "when the request is about a specific specification" do
      it "links to the specification" do
        expect(page).to have_link "Continue with your specification", href: "/journeys/#{journey.id}"
      end
    end

    context "when the request is about a category" do
      let(:support_request) do
        create(:support_request, user: journey.user, category: category, school_urn: "urn-type-1")
      end

      it "has no specification link" do
        expect(page).not_to have_link "Continue with your specification"
      end
    end
  end

  describe "unsubmitted request" do
    before do
      visit "/support-request-submissions/#{support_request.id}"
    end

    it "redirects to support request summary" do
      expect(page).to have_current_path "/support-requests/#{support_request.id}"
    end
  end
end
