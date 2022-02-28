RSpec.feature "Creating a 'Find a Framework' request as a guest" do
  include_context "with schools and groups"

  def confirm_choice_step
    choose "Yes"
    click_continue
  end

  def complete_name_step
    fill_in "framework_support_form[first_name]", with: "Test"
    fill_in "framework_support_form[last_name]", with: "User"
    click_continue
  end

  def complete_email_step
    fill_in "framework_support_form[email]", with: "test@email.com"
    click_continue
  end

  def autocomplete_school_step
    # missing last digit
    fill_in "Enter the name, postcode or unique reference number (URN) of your school", with: "10025"
    find(".autocomplete__option", text: "Greendale Academy for Bright Sparks").click
    click_continue
  end

  def autocomplete_group_step
    # missing last digit
    fill_in "Enter name, Unique group identifier (UID) or UK Provider Reference Number (UKPRN)", with: "231"
    find(".autocomplete__option", text: "New Academy Trust").click
    click_continue
  end

  def complete_help_message_step
    fill_in "framework_support_form[message_body]", with: "I have a problem"
    click_continue
  end

  let(:keys) { all("dt.govuk-summary-list__key") }
  let(:values) { all("dd.govuk-summary-list__value") }
  let(:actions) { all("dd.govuk-summary-list__actions") }

  before do
    visit "/procurement-support/new"
    choose "No, continue without a DfE Sign-in account"
    click_continue
  end

  describe "the organisation type choice page" do
    it "goes back to the login choice page" do
      click_on "Back"

      within("div.govuk-form-group") do
        expect(find("span.govuk-caption-l")).to have_text "About your school"
        expect(page).to have_text "Do you have a DfE Sign-in account linked to the school that your request is about?"
      end
    end

    it "asks for school or group" do
      expect(find("legend.govuk-fieldset__legend--l")).to have_text "What type of organisation are you buying for?"
    end

    it "validates a choice is made" do
      click_continue

      expect(find("h2.govuk-error-summary__title")).to have_text "There is a problem"
      expect(page).to have_link "Select what type of organisation you're buying for", href: "#framework-support-form-group-field-error"
    end
  end

  context "when selecting a single school", js: true do
    before do
      choose "A single school"
      click_continue
    end

    describe "the school search page" do
      it "goes back to the organisation choice page" do
        click_on "Back"

        expect(page).to have_current_path(/step%5D=3/)
        expect(page).to have_current_path(/back%5D=true/)
        expect(find("legend.govuk-fieldset__legend--l")).to have_text "What type of organisation are you buying for?"
      end

      it "has the correct attributes" do
        expect(find("span.govuk-caption-l")).to have_text "About your school"
        expect(find("h1.govuk-heading-l")).to have_text "Search for your school"

        expect(page).to have_field "Enter the name, postcode or unique reference number (URN) of your school"

        within(find("details.govuk-details")) do
          expect(find("span.govuk-details__summary-text")).to have_text "Can't find it?"

          expect(page).to have_text "This search lists single schools in England, such as local authority maintained schools, or an academy in a single or multi-academy trust. Search for an academy trust or federation instead."
          expect(page).to have_text "This service is available to all state-funded primary, secondary, special and alternative provision schools with pupils aged between 5 to 16 years old."
          expect(page).to have_text "Private, voluntary-aided and independent early years providers and institutions with pupils aged 16 years and above are not eligible for this service."

          expect(page).to have_link "Search for an academy trust or federation instead."
        end

        expect(page).to have_button "Continue"
      end

      it "links to the group search page" do
        find("span", text: "Can't find it?").click
        click_on "Search for an academy trust or federation"

        expect(find("h1.govuk-heading-l")).to have_text "Search for an academy trust or federation"

        autocomplete_group_step

        expect(find("h1.govuk-heading-l")).to have_text "Is this the academy trust or federation you're buying for?"

        expect(values[0]).to have_text "New Academy Trust,"
        expect(values[1]).to have_text "Boundary House Shr, 91 Charter House Street, EC1M 6HR"
      end

      it "validates the selected school" do
        click_continue

        expect(find("h2.govuk-error-summary__title")).to have_text "There is a problem"
        expect(page).to have_link "Select the school you want help buying for", href: "#framework-support-form-org-id-field-error"
      end
    end

    describe "the school confirmation page" do
      before do
        autocomplete_school_step
      end

      it "goes back to the school search page and retains the autocompleted result" do
        click_on "Back"

        expect(page).to have_current_path(/step%5D=4/)
        expect(page).to have_current_path(/back%5D=true/)
        expect(page).to have_current_path(/group%5D=false/)

        expect(find("h1.govuk-heading-l")).to have_text "Search for your school"
        expect(find_field("framework-support-form-org-id-field").value).to eql "100254 - Greendale Academy for Bright Sparks"
      end

      it "has the correct attributes" do
        expect(find("span.govuk-caption-l")).to have_text "About your school"
        expect(find("h1.govuk-heading-l")).to have_text "Is this the school you're buying for?"

        expect(keys[0]).to have_text "Name and Address"
        expect(values[0]).to have_text "Greendale Academy for Bright Sparks, St James's Passage, Duke's Place, EC3A 5DE"

        expect(keys[1]).to have_text "Local authority"
        expect(values[1]).to have_text "Camden"

        expect(keys[2]).to have_text "Headteacher / Principal"
        expect(values[2]).to have_text "Ms Head Teacher"

        expect(keys[3]).to have_text "Phase of education"
        expect(values[3]).to have_text "All through"

        expect(keys[4]).to have_text "School type"
        expect(values[4]).to have_text "Community school"

        expect(keys[5]).to have_text "ID"
        expect(values[5]).to have_text "URN: 100254 DfE number: 334 UKPRN: 4346"

        expect(page).to have_unchecked_field "Yes"
        expect(page).to have_unchecked_field "No, I need to choose another school"
        expect(page).to have_button "Continue"
      end

      it "choosing no goes back to the school search page" do
        choose "No, I need to choose another school"
        click_continue
        expect(page).to have_current_path "/procurement-support"
        expect(find("h1.govuk-heading-l")).to have_text "Search for your school"
      end

      it "choosing yes continues to the name page" do
        choose "Yes"
        click_continue
        expect(page).to have_current_path "/procurement-support"
        expect(find("h1.govuk-heading-l")).to have_text "What is your name?"
      end
    end

    describe "the name page" do
      before do
        autocomplete_school_step
        confirm_choice_step
      end

      it "goes back to the school confirmation page" do
        click_on "Back"
        expect(page).to have_current_path(/step%5D=5/)
        expect(page).to have_current_path(/back%5D=true/)
        expect(find("h1.govuk-heading-l")).to have_text "Is this the school you're buying for?"
      end

      it "asks for their full name" do
        expect(find("span.govuk-caption-l")).to have_text "About you"
        expect(find("h1.govuk-heading-l")).to have_text "What is your name?"

        expect(page).to have_field "First Name"
        expect(page).to have_field "Last Name"

        expect(page).to have_button "Continue"
      end

      it "validates their name" do
        click_continue

        expect(find("h2.govuk-error-summary__title")).to have_text "There is a problem"
        expect(page).to have_link "Enter your first name", href: "#framework-support-form-first-name-field-error"
        expect(page).to have_link "Enter your last name", href: "#framework-support-form-last-name-field-error"
      end
    end

    describe "the email address page" do
      before do
        autocomplete_school_step
        confirm_choice_step
        complete_name_step
      end

      it "goes back to the name page" do
        click_on "Back"
        expect(page).to have_current_path(/step%5D=6/)
        expect(page).to have_current_path(/back%5D=true/)
        expect(find("h1.govuk-heading-l")).to have_text "What is your name?"
      end

      it "has the correct attributes" do
        expect(find("span.govuk-caption-l")).to have_text "About you"
        expect(find("label.govuk-label--l")).to have_text "What is your email address?"

        expect(page).to have_field "We will only use this to contact you about your request."

        expect(page).to have_button "Continue"
      end

      it "validates their email" do
        click_continue

        expect(find("h2.govuk-error-summary__title")).to have_text "There is a problem"
        expect(page).to have_link "Enter an email in the correct format. For example, 'someone@school.sch.uk'.", href: "#framework-support-form-email-field-error"
      end
    end

    describe "the message text page" do
      before do
        autocomplete_school_step
        confirm_choice_step
        complete_name_step
        complete_email_step
      end

      it "goes back to the email address page" do
        click_on "Back"
        expect(page).to have_current_path(/step%5D=7/)
        expect(page).to have_current_path(/back%5D=true/)
        expect(find("label.govuk-label--l")).to have_text "What is your email address?"
      end

      it "has the correct attributes" do
        expect(find("span.govuk-caption-l")).to have_text "About your request"
        expect(find("label.govuk-label--l")).to have_text "How can we help?"

        expect(find("div.govuk-hint")).to have_text "Briefly describe what advice or guidance you need in a few sentences."
        expect(page).to have_field "framework_support_form[message_body]"

        expect(page).to have_button "Continue"
      end

      it "validates the message is entered" do
        click_continue

        expect(find("h2.govuk-error-summary__title")).to have_text "There is a problem"
        expect(page).to have_link "You must tell us how we can help", href: "#framework-support-form-message-body-field-error"
      end
    end
  end

  context "when selecting a group or trust", js: true do
    before do
      choose "An academy trust or federation"
      click_continue
    end

    describe "the search for a group page" do
      it "goes back to the organisation choice page" do
        click_on "Back"
        expect(page).to have_current_path(/step%5D=3/)
        expect(page).to have_current_path(/back%5D=true/)
        expect(find("legend.govuk-fieldset__legend--l")).to have_text "What type of organisation are you buying for?"
      end

      it "has the correct attributes" do
        expect(find("span.govuk-caption-l")).to have_text "About your school"
        expect(find("h1.govuk-heading-l")).to have_text "Search for an academy trust or federation"

        expect(page).to have_field "Enter name, Unique group identifier (UID) or UK Provider Reference Number (UKPRN)"

        within(find("details.govuk-details")) do
          expect(find("span.govuk-details__summary-text")).to have_text "Can't find it?"
          expect(page).to have_text "This search lists academy trusts and federations. Search for a single school instead."
          expect(page).to have_text "This service is available to all state-funded primary, secondary, special and alternative provision schools with pupils aged between 5 to 16 years old."
          expect(page).to have_text "Private, voluntary-aided and independent early years providers and institutions with pupils aged 16 years and above are not eligible for this service."

          expect(page).to have_link "Search for a single school instead."
        end

        expect(page).to have_button "Continue"
      end

      it "links to the school search page" do
        find("span", text: "Can't find it?").click

        click_on "Search for a single school instead."
        expect(find("h1.govuk-heading-l")).to have_text "Search for your school"

        autocomplete_school_step

        expect(page).to have_text "Is this the school you're buying for?"

        expect(values[0]).to have_text "Greendale Academy for Bright Sparks, St James's Passage, Duke's Place, EC3A 5DE"
      end

      it "validates the selected group" do
        click_continue

        expect(find("h2.govuk-error-summary__title")).to have_text "There is a problem"
        expect(page).to have_link "Enter your academy trust or federation name, or UKPRN and select it from the list", href: "#framework-support-form-org-id-field-error"
      end
    end

    describe "the group confirmation page" do
      before do
        autocomplete_group_step
      end

      it "goes back to the group search page" do
        click_on "Back"
        expect(page).to have_current_path(/step%5D=4/)
        expect(page).to have_current_path(/back%5D=true/)
        expect(find("h1.govuk-heading-l")).to have_text "Search for an academy trust or federation"
      end

      it "validates the group is confirmed" do
        click_continue

        expect(find("h2.govuk-error-summary__title")).to have_text "There is a problem"
        expect(page).to have_link "Select whether this is the Group or Trust you're buying for", href: "#framework-support-form-org-confirm-field-error"
      end

      it "choosing no goes back to the group search page" do
        choose "No, I need to choose another academy trust or federation"
        click_continue
        expect(page).to have_current_path "/procurement-support"
        expect(page).to have_text "Search for an academy trust or federation"
      end

      it "choosing yes continues to the name page" do
        choose "Yes"
        click_continue
        expect(page).to have_current_path "/procurement-support"
        expect(find("h1.govuk-heading-l")).to have_text "What is your name?"
      end

      it "has the correct attributes" do
        expect(find("span.govuk-caption-l")).to have_text "About your school"
        expect(find("h1.govuk-heading-l")).to have_text "Is this the academy trust or federation you're buying for?"

        expect(keys[0]).to have_text "Group name"
        expect(values[0]).to have_text "New Academy Trust,"

        expect(keys[1]).to have_text "Address"
        expect(values[1]).to have_text "Boundary House Shr, 91 Charter House Street, EC1M 6HR"

        expect(keys[2]).to have_text "Group type"
        expect(values[2]).to have_text "Single-academy Trust"

        expect(keys[3]).to have_text "ID"
        expect(values[3]).to have_text "UID: 2315 UKPRN: 1010010"

        expect(page).to have_unchecked_field "Yes"
        expect(page).to have_unchecked_field "No, I need to choose another academy trust or federation"
        expect(page).to have_button "Continue"
      end
    end
  end
end
