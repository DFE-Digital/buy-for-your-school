RSpec.feature "Starting a 'Digital Support' request" do
  let(:user) { create(:user, :one_supported_school) }

  describe "start page" do
    before do
      user_is_signed_in(user:)
      visit "/support-requests"
    end

    specify { expect(page).to have_current_path "/support-requests" }

    it "support_requests.start.h1_heading" do
      expect(find("h1.govuk-heading-xl")).to have_text "Request help and support with your specification"
    end

    it "explains the form to the user" do
      expect(find("div.govuk-grid-column-two-thirds", text: "Use this service to request free advice and support from our procurement experts for help with your catering or multi-functional devices specification.")).to be_present
      expect(find("div.govuk-grid-column-two-thirds", text: "DfE's supported buying team will respond to you within 2 working days.")).to be_present
    end

    it "links to more information" do
      expect(page).to have_link "read about writing a specification",
                                href: "https://www.gov.uk/guidance/buying-procedures-and-procurement-law-for-schools/writing-a-specification",
                                class: "govuk-link"

      expect(page).to have_link "planning for what you're buying",
                                href: "https://www.gov.uk/guidance/buying-for-schools",
                                class: "govuk-link"

      expect(page).to have_link "information on finding the right way to buy",
                                href: "https://www.gov.uk/guidance/buying-procedures-and-procurement-law-for-schools",
                                class: "govuk-link"

      expect(page).to have_link "find a framework service",
                                href: "https://www.gov.uk/guidance/find-a-dfe-approved-framework-for-your-school",
                                class: "govuk-link"
    end

    it "confirms your identity on the profile page" do
      expect(find("a.govuk-button")).to have_text "Start"
      click_on "Start"

      expect(page).to have_current_path "/profile"
      click_on "Request support"

      expect(page).to have_current_path "/support-requests/new"
    end
  end
end
