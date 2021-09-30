RSpec.feature "Show a support request" do
  let(:category) { create(:category) }
  let(:journey) { create(:journey, category: category) }
  let(:support_request) { create(:support_request, journey: journey, category: category, user: journey.user) }

  context "when the user is signed in" do
    before do
      user_is_signed_in(user: journey.user)
      visit "/users/#{journey.user.id}/support-requests/#{support_request.id}"
    end

    specify { expect(page).to have_current_path "/users/#{journey.user.id}/support-requests/#{support_request.id}" }

    it "support_requests.sections.send_your_request" do
      expect(find("h1.govuk-heading-l")).to have_text "Send your request"
    end

    it "support_requests.buttons.send" do
      expect(find("a.govuk-button")).to have_text "Send request"
      expect(find("a.govuk-button")[:role]).to eq "button"
    end
  end
end
