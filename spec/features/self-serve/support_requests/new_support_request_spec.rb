RSpec.feature "Create a new support request" do
  before do
    travel_to Time.zone.local(2021, 9, 1, 0o1, 0o4, 44)
  end

  let(:journey) { create(:journey) }

  context "when the user is signed in" do
    before do
      user_is_signed_in(user: journey.user)
      visit "/users/#{journey.user.id}/support-requests"
    end

    specify { expect(page).to have_current_path "/users/#{journey.user.id}/support-requests" }

    it "support_requests.start.h1_heading" do
      expect(find("h1.govuk-heading-xl")).to have_text "Request help and support with your specification"
    end

    it "generic.button.start" do
      expect(find("a.govuk-button")).to have_text "Start"
      expect(find("a.govuk-button")[:role]).to eq "button"
    end

    scenario "they can confirm their contact details" do
      click_on "Start"

      expect(find("h1.govuk-heading-l")).to have_text "Is this your contact information?"
      expect(find("a.govuk-button")).to have_text "Yes, continue"
      expect(find("a.govuk-button")[:role]).to eq "button"
    end

    context "when all steps are completed" do
      scenario "they can complete a support request" do
        click_on "Start"
        click_on "Yes, continue"

        expect(find("label.govuk-label--l")).to have_text "Which of your specifications are related to this request?"

        choose "1 September 2021"
        click_continue

        expect(find("label.govuk-label--l")).to have_text "What are you buying?"

        choose "category title"
        click_continue

        expect(find("label.govuk-label--l")).to have_text "How can we help?"

        fill_in "support_form_wizard[message]", with: "This is my long answer"
        click_continue

        expect(find("div#flash_notice")).to have_text "Support request created"
      end
    end
  end
end
