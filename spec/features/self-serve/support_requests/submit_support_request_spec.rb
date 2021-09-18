RSpec.feature "Submit a completed support request" do
  let(:category) { create(:category) }
  let(:journey) { create(:journey, category: category) }

  let(:support_request) do
    create(:support_request,
           user: journey.user,
           journey: journey,
           category: category)
  end

  before do
    user_is_signed_in(user: journey.user)
    visit "/support-requests/#{support_request.id}"
  end

  specify { expect(page).to have_current_path "/support-requests/#{support_request.id}" }

  describe "summary" do
    it "support_requests.sections.send_your_request" do
      expect(find("h1.govuk-heading-l")).to have_text "Send your request"
    end

    it "support_requests.buttons.send" do
      expect(find("a.govuk-button")).to have_text "Send request"
      expect(find("a.govuk-button")[:role]).to eq "button"
    end

    it "has section headings" do
      headings = find_all("h2.govuk-heading-m")

      expect(headings[0]).to have_text "About you"
      expect(headings[1]).to have_text "About your request for support"
    end

    it "confirms the expected response time" do
      # support_requests.response_time
      expect(find("p.govuk-body")).to have_text "Once you send this request, we will review it and get in touch within 5 working days."
    end
  end
end
