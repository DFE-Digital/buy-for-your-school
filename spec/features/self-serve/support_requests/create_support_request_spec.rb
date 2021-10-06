RSpec.feature "Create a new support request" do
  describe "start page" do
    before do
      user_is_signed_in
      visit "/support-requests"
    end

    specify { expect(page).to have_current_path "/support-requests" }

    it "support_requests.start.h1_heading" do
      expect(find("h1.govuk-heading-xl")).to have_text "Request help and support with your specification"
    end

    it "explains the form to the user" do
      expect(page).to have_text "Use this service to request free advice and support from our procurement experts for help with your catering or multi-functional devices specification."
      expect(page).to have_text "DfE's supported buying team will respond to you within 5 working days."
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

    it "generic.button.start" do
      expect(find("a.govuk-button")).to have_text "Start"
      expect(find("a.govuk-button")[:role]).to eq "button"
    end
  end

  describe "contact details" do
    before do
      user_is_signed_in
      visit "/support-requests/new"
    end

    it "does not reveal debug information" do
      expect(find_all("pre.debug_dump")).to be_empty
    end

    # step 1
    it "asks for a phone number" do
      expect(find("span.govuk-caption-l")).to have_text "About you"
      expect(find("label.govuk-label--l")).to have_text "What is your phone number?"
      expect(find("span.govuk-hint")).to have_text "Your phone number will be used by DfE's supported buying team to contact you about your request for help. It will not be used for marketing or any other purposes. You do not need to provide a phone number."
    end

    # step 1 > step 3
    it "does not require a phone number" do
      click_continue
      expect(find("legend.govuk-fieldset__legend--l")).to have_text "What are you buying?"
    end

    context "with valid data" do
      # step 1 > step 3
      it "validates a phone number (valid)" do
        fill_in "support_form[phone_number]", with: "01234567890"
        click_continue
        expect(find("legend.govuk-fieldset__legend--l")).to have_text "What are you buying?"
      end
    end

    context "with invalid data it validates a phone number" do
      # step 1
      it "(min size)" do
        fill_in "support_form[phone_number]", with: "0123"
        click_continue
        expect(find("h2.govuk-error-summary__title")).to have_text "There is a problem"
        expect(page).to have_link "Your phone number must have a minimum of 10 numbers and no spaces, starting with a zero", href: "#support-form-phone-number-field-error"
        expect(find("span.govuk-error-message")).to have_text "Your phone number must have a minimum of 10 numbers and no spaces, starting with a zero"
      end

      # step 1
      it "(leading zero)" do
        fill_in "support_form[phone_number]", with: "11234567890"
        click_continue
        expect(find("h2.govuk-error-summary__title")).to have_text "There is a problem"
        expect(page).to have_link "Your phone number must have a minimum of 10 numbers and no spaces, starting with a zero", href: "#support-form-phone-number-field-error"
        expect(find("span.govuk-error-message")).to have_text "Your phone number must have a minimum of 10 numbers and no spaces, starting with a zero"
      end

      # step 1
      it "(only numbers)" do
        fill_in "support_form[phone_number]", with: "0123456789x"
        click_continue
        expect(find("h2.govuk-error-summary__title")).to have_text "There is a problem"
        expect(page).to have_link "Your phone number must have a minimum of 10 numbers and no spaces, starting with a zero", href: "#support-form-phone-number-field-error"
        expect(find("span.govuk-error-message")).to have_text "Your phone number must have a minimum of 10 numbers and no spaces, starting with a zero"
      end

      # step 1
      it "(max size)" do
        fill_in "support_form[phone_number]", with: "012345678901"
        click_continue
        expect(find("h2.govuk-error-summary__title")).to have_text "There is a problem"
        expect(page).to have_link "Your phone number can not have more than 11 digits", href: "#support-form-phone-number-field-error"
        expect(find("span.govuk-error-message")).to have_text "Your phone number can not have more than 11 digits"
      end
    end
  end

  context "when the user has existing specs" do
    let(:user) { create(:user, first_name: "Peter", last_name: "Hamilton", email: "ghbfs@example.com") }
    let(:category) { create(:category, title: "Laptops") }
    let(:journey) { create(:journey, category: category, user: user) }

    before do
      # TODO: use `title` and remove `travel_to` used to control `created_at`
      travel_to Time.zone.local(2021, 9, 1, 0o1, 0o4, 44)

      user_is_signed_in(user: journey.user)
      visit "/support-requests/new"
      click_continue
    end

    # step 2
    it "asks them to choose which spec" do
      expect(find("legend.govuk-fieldset__legend--l")).to have_text "Which specification is this related to?"
      expect(find("span.govuk-caption-l")).to have_text "Share a specification"
    end

    # step 2
    it "defaults to none (last option)" do
      expect(find_all("label.govuk-radios__label")[1]).to have_text "My request is not related to an existing specification"

      expect(page).to have_checked_field "support-form-journey-id-none-field"
    end

    # step 4 (last)
    it "infers the category from the chosen spec" do
      choose "1 September 2021"
      click_continue

      expect(find("span.govuk-caption-l")).to have_text "About your procurement"
      expect(find("label.govuk-label--l")).to have_text "How can we help?"
      expect(find("span.govuk-hint")).to have_text "Briefly describe your problem in a few sentences."
    end
  end

  context "when the user has not started a spec" do
    before do
      create(:category, title: "Maintenance")
      create(:category, title: "Broadband")

      user_is_signed_in
      visit "/support-requests/new"
      click_continue
    end

    it "does not reveal debug information" do
      expect(find_all("pre.debug_dump")).to be_empty
    end

    # jumps to step 3
    it "requires they choose a category" do
      expect(find("legend.govuk-fieldset__legend--l")).to have_text "What are you buying?"
      expect(find("span.govuk-caption-l")).to have_text "About your procurement"

      expect(page).to have_unchecked_field "Broadband"
      expect(page).to have_unchecked_field "Maintenance"

      # FIXME: category validation errors are not appearing
      # click_continue

      # expect(find("h2.govuk-error-summary__title")).to have_text "There is a problem"
      # expect(page).to have_link "The type of procurement is required if you do not select an existing specification", href: "#support-form-category_id-field-error"
      # expect(find("span.govuk-error-message")).to have_text "The type of procurement is required if you do not select an existing specification"

      # choose "Broadband"
      # click_continue

      # expect(find("span.govuk-hint")).to have_text "Briefly describe your problem in a few sentences."
    end
  end

  # step 4
  describe "a message" do
    before do
      create(:category, title: "Maintenance")

      user_is_signed_in
      visit "/support-requests/new"
      click_continue
      choose "Maintenance"
      click_continue
    end

    it "is essential" do
      click_continue

      expect(find("h2.govuk-error-summary__title")).to have_text "There is a problem"
      expect(page).to have_link "You must tell us how we can help", href: "#support-form-message-body-field-error"
      expect(find("span.govuk-error-message")).to have_text "You must tell us how we can help"
    end
  end

  # show
  describe "a completed support request" do
    let(:user) { create(:user, first_name: "Peter", last_name: "Hamilton", email: "ghbfs@example.com") }

    let(:answers) { find_all("dd.govuk-summary-list__value") }

    before do
      create(:category, title: "Laptops")
      user_is_signed_in(user: user)

      visit "/support-requests/new"
      click_continue

      choose "Laptops"
      click_continue

      fill_in "support_form[message_body]", with: "I have a problem"
      click_continue
    end

    it "does not reveal debug information" do
      expect(find_all("pre.debug_dump")).to be_empty
    end

    it "shows the answers" do
      expect(answers[0]).to have_text "Peter Hamilton"
      expect(answers[1]).to have_text "ghbfs@example.com"
      expect(answers[2]).to have_text ""      # phone number
      expect(answers[3]).to have_text "None"  # specification
      expect(answers[4]).to have_text "Laptops"
      expect(answers[5]).to have_text "I have a problem"
    end

    it "is not automatically submitted" do
      expect(find_button("Send request")).to be_present
      expect(SupportRequest.last).not_to be_submitted
    end
  end
end
