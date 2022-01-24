RSpec.feature "Faf - update request" do
  context "when on the DSI journey" do
    let(:user) { create(:user, :one_supported_school) }
    let(:framework_request) { create(:framework_request, user: user, school_urn: "urn-type-1") }

    before do
      user_is_signed_in(user: user)
      visit "/procurement-support/#{framework_request.id}"
    end

    it "allows the user to change the message body" do
      within("dl.govuk-summary-list") do
        expect(all("dd.govuk-summary-list__actions").last).to have_link "Change"
      end

      # change the message body
      click_on "Change"

      # message page
      expect(page).to have_current_path "/procurement-support/#{framework_request.id}/edit?step=4"
      expect(find("textarea.govuk-textarea")).to have_text "please help!"

      fill_in "faf_form[message_body]", with: "I have a problem"
      click_continue

      # back to the CYA page
      expect(page).to have_current_path "/procurement-support/#{framework_request.id}"
      expect(all("dd.govuk-summary-list__value")[3]).to have_text "I have a problem"
    end

    context "when there is one supported school" do
      it "does not allow to change the school" do
        within("dl.govuk-summary-list") do
          expect(all("dd.govuk-summary-list__actions")[2]).not_to have_link "Change"
        end
      end
    end

    context "when there are multiple supported schools" do
      let(:user) { create(:user, :many_supported_schools) }

      before do
        create(:support_organisation, urn: "urn-type-1", name: "School #1")
        create(:support_organisation, urn: "greendale-urn", name: "Greendale Academy for Bright Sparks")
      end

      it "allows the user to change the school" do
        # change the school
        within(all("dd.govuk-summary-list__actions")[2]) do
          click_on "Change"
        end

        # school page
        expect(page).to have_current_path "/procurement-support/#{framework_request.id}/edit?step=3"
        expect(find("input#faf-form-school-urn-urn-type-1-field")).to be_checked

        choose "Greendale Academy for Bright Sparks"
        click_continue

        # back to the CYA page
        expect(page).to have_current_path "/procurement-support/#{framework_request.id}"
        expect(all("dd.govuk-summary-list__value")[2]).to have_text "Greendale Academy for Bright Sparks"
      end
    end
  end
end
