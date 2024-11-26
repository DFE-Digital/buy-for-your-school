RSpec.feature "Creating a 'Digital Support' request" do
  let(:user) { create(:user, :one_supported_school) }

  describe "contact details" do
    before do
      user_is_signed_in(user:)
      visit "/support-requests/new"
    end

    it "does not reveal debug information" do
      expect(find_all("pre.debug_dump")).to be_empty
    end

    it "starts off at step 4" do
      expect(find("legend.govuk-fieldset__legend--l")).to have_text "What are you buying?"
    end
  end

  describe "school details" do
    before do
      user_is_signed_in(user:)
      visit "/support-requests/new"
    end

    context "when the user belongs to only one supported school" do
      it "skips step 2 because the school is implicit" do
        expect(page).not_to have_unchecked_field "Specialist School for Testing"
        expect(find("span.govuk-caption-l")).to have_text "About your procurement"
      end
    end

    context "when the user belongs to multiple supported schools" do
      let(:user) { create(:user, :many_supported_schools) }

      it "asks them to choose which school" do
        expect(page).to have_unchecked_field "Specialist School for Testing"
        expect(page).to have_unchecked_field "Greendale Academy for Bright Sparks"
      end

      it "requires a school be selected" do
        click_continue
        expect(find("h2.govuk-error-summary__title")).to have_text "There is a problem"
        expect(page).to have_link "You must select a school", href: "#support-form-school-urn-field-error"
        expect(find(".govuk-error-message")).to have_text "You must select a school"
      end
    end
  end

  context "when the user has existing specs" do
    let(:user) { create(:user, :one_supported_school, first_name: "Peter", last_name: "Hamilton", email: "ghbfs@example.com") }
    let(:category) { create(:category, title: "Laptops") }
    let(:journey) { create(:journey, category:, user:) }

    before do
      # TODO: use `title` and remove `travel_to` used to control `created_at`
      travel_to Time.zone.local(2021, 9, 1, 0o1, 0o4, 44)

      user_is_signed_in(user: journey.user)
      visit "/support-requests/new"
    end

    # step 3
    it "asks them to choose which spec" do
      expect(find("legend.govuk-fieldset__legend--l")).to have_text "Which specification is this related to?"
      expect(find("span.govuk-caption-l")).to have_text "Share a specification"
    end

    # step 3
    it "defaults to none (last option)" do
      expect(find_all("label.govuk-radios__label")[1]).to have_text "My request is not related to an existing specification"

      expect(page).to have_checked_field "support-form-journey-id-none-field"
    end

    # step 5 (last)
    it "infers the category from the chosen spec" do
      choose "1 September 2021"
      click_continue
      expect(find("span.govuk-caption-l")).to have_text "About your procurement"
      expect(find("label.govuk-label--l")).to have_text "How can we help?"
      expect(find(".govuk-hint")).to have_text "Briefly describe your problem in a few sentences."
    end
  end

  xcontext "when the user has not started a spec" do
    before do
      create(:category, title: "Maintenance")
      create(:category, title: "Broadband")

      user_is_signed_in(user:)
      visit "/support-requests/new"
      click_continue
    end

    it "does not reveal debug information" do
      expect(find_all("pre.debug_dump")).to be_empty
    end

    # jumps to step 4
    it "requires they choose a category" do
      expect(find("legend.govuk-fieldset__legend--l")).to have_text "What are you buying?"
      expect(find("span.govuk-caption-l")).to have_text "About your procurement"

      expect(page).to have_unchecked_field "Broadband"
      expect(page).to have_unchecked_field "Maintenance"

      click_continue

      expect(find("h2.govuk-error-summary__title")).to have_text "There is a problem"
      expect(page).to have_link "The type of procurement is required if you do not select an existing specification", href: "#support-form-category-id-field-error"
      expect(find(".govuk-error-message")).to have_text "The type of procurement is required if you do not select an existing specification"

      choose "Broadband"
      click_continue

      expect(find(".govuk-hint")).to have_text "Briefly describe your problem in a few sentences."
    end
  end

  # step 5
  describe "a message" do
    before do
      create(:category, title: "Maintenance")

      user_is_signed_in(user:)
      visit "/support-requests/new"
      click_continue
      choose "Maintenance"
      click_continue
    end

    it "is essential" do
      click_continue

      expect(find("h2.govuk-error-summary__title")).to have_text "There is a problem"
      expect(page).to have_link "You must tell us how we can help", href: "#support-form-message-body-field-error"
      expect(find(".govuk-error-message")).to have_text "You must tell us how we can help"
    end

    it "goes back to the previous step when the back link is clicked" do
      find(".govuk-back-link").click

      expect(find("span.govuk-caption-l")).to have_text "About your procurement"
    end
  end

  # show
  describe "a completed support request" do
    let(:user) { create(:user, :one_supported_school, first_name: "Peter", last_name: "Hamilton", email: "ghbfs@example.com") }

    let(:answers) { find_all("dd.govuk-summary-list__value") }

    before do
      create(:category, title: "Laptops")
      user_is_signed_in(user:)

      visit "/support-requests/new"
      click_continue

      choose "Laptops"
      click_continue

      fill_in "support_form[message_body]", with: "I have a problem"
      click_continue

      click_continue

      choose "No"
      click_continue
    end

    it "does not reveal debug information" do
      expect(find_all("pre.debug_dump")).to be_empty
    end

    it "shows the answers" do
      expect(answers[0]).to have_text "Peter Hamilton"
      expect(answers[1]).to have_text "ghbfs@example.com"
      # expect(answers[2]).to have_text "" # phone number
      expect(answers[2]).to have_text "Specialist School for Testing" # school autoselected due to only having one to choose from
      expect(answers[3]).to have_text "None" # specification
      expect(answers[4]).to have_text "Laptops"
      expect(answers[5]).to have_text "I have a problem"
    end

    it "is not automatically submitted" do
      expect(find_button("Send request")).to be_present
      expect(SupportRequest.last).not_to be_submitted
    end
  end
end
