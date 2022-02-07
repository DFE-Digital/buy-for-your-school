RSpec.feature "Create a new framework request through non-DSI journey" do
  before do
    create(:support_organisation, urn: "100253", name: "School #1")
    stub_request(:post, "https://api.notifications.service.gov.uk/v2/notifications/email")
    .to_return(body: {}.to_json, status: 200, headers: {})
    visit "/procurement-support/new"
    find("label", text: "No, continue without a DfE Sign-in account").click
    click_continue
  end

  describe "what type of organisation page" do
    it "has a back link to the 'Do you have a DfE Sign-in' page" do
      click_on "Back"
      within("div.govuk-form-group") do
        expect(find("span.govuk-caption-l")).to have_text "About your school"
        expect(page).to have_text "Do you have a DfE Sign-in account linked to the school that your request is about?"
      end
    end

    it "loads the page" do
      expect(page).to have_text "What type of organisation are you buying for?"
    end

    it "errors if no selection is given" do
      click_continue
      expect(find(".govuk-error-summary__body")).to have_text "Select what type of organisation you're buying for"
    end
  end

  context "when single school", js: true do
    let(:user) { create(:user, :one_supported_school, first_name: "Generic", last_name: "User", full_name: "Generic User") }
    let(:answers) { find_all("dd.govuk-summary-list__value") }

    describe "what is your name page" do
      before do
        find("label", text: "A single school").click
        click_continue
      end

      it "has the correct attributes" do
        expect(find("span.govuk-caption-l")).to have_text "About you"
        expect(find("h1.govuk-heading-l")).to have_text "What is your name?"
      end

      it "raises a validation error when nothing entered" do
        click_continue
        expect(find("h2.govuk-error-summary__title")).to have_text "There is a problem"
        expect(page).to have_link "Enter your first name", href: "#framework-support-form-first-name-field-error"
        expect(all(".govuk-error-message")[0]).to have_text "Enter your first name"
        expect(page).to have_link "Enter your last name", href: "#framework-support-form-last-name-field-error"
        expect(all(".govuk-error-message")[1]).to have_text "Enter your last name"
      end

      it "navigates to the next page when user enters their details" do
        fill_in "framework_support_form[first_name]", with: "Jim"
        fill_in "framework_support_form[last_name]", with: "Jones"
        click_continue

        expect(find("h1.govuk-label-wrapper")).to have_text "What is your email address?"
      end
    end
  end

  # xcontext "when group or trust", js: true do
  # end
end
