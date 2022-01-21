RSpec.feature "FaF - check your answers" do
  let(:user) { create(:user, :one_supported_school) }

  context "when the user is signed in" do
    before do
      create(:support_organisation, urn: "urn-type-1")

      user_is_signed_in(user: user)
      # start DSI journey
      visit "/procurement-support/new"
      # step1
      choose "Yes, use my DfE Sign-in"
      click_continue
      # step 2
      click_on "Yes, continue"
      # step 4
      fill_in "faf_form[message_body]", with: "I have a problem"
      click_continue
    end

    it "shows the CYA page" do
      expect(find("h1.govuk-heading-l")).to have_text "Send your request"
      within("dl.govuk-summary-list") do
        expect(all("dt.govuk-summary-list__key")[0]).to have_text "Your name"
        expect(all("dd.govuk-summary-list__value")[0]).to have_text "first_name last_name"
        expect(all("dd.govuk-summary-list__actions")[0]).not_to have_link "Change"

        expect(all("dt.govuk-summary-list__key")[1]).to have_text "Your email address"
        expect(all("dd.govuk-summary-list__value")[1]).to have_text "test@test"
        expect(all("dd.govuk-summary-list__actions")[1]).not_to have_link "Change"

        expect(all("dt.govuk-summary-list__key")[2]).to have_text "Your school"
        expect(all("dd.govuk-summary-list__value")[2]).to have_text "School #1"
        expect(all("dd.govuk-summary-list__actions")[2]).to have_link "Change"

        expect(all("dt.govuk-summary-list__key")[3]).to have_text "Description of problem"
        expect(all("dd.govuk-summary-list__value")[3]).to have_text "I have a problem"
        expect(all("dd.govuk-summary-list__actions")[3]).to have_link "Change"
      end
      expect(find("p.govuk-body")).to have_text "Once you send this request, we will review it and get in touch within 2 working days."
      expect(page).to have_button "Send request"
    end
  end
end
