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

  def complete_procurement_amount_step
    fill_in "framework_support_form[procurement_amount]", with: "120.32"
    click_continue
  end

  let(:keys) { all("dt.govuk-summary-list__key") }
  let(:values) { all("dd.govuk-summary-list__value") }
  let(:actions) { all("dd.govuk-summary-list__actions") }

  before do
    visit "/procurement-support/sign_in"
    choose "No, continue without a DfE Sign-in account"
    click_continue
  end

  describe "the organisation type choice page" do
    it "asks for school or group" do
      expect(find("legend.govuk-fieldset__legend--l")).to have_text "What type of organisation are you buying for?"
    end
  end

  context "when selecting a single school", js: true do
    before do
      choose "A single school"
      click_continue
    end

    describe "the school search page" do
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

        expect(page).not_to have_text "There is a problem"
        expect(find("h1.govuk-heading-l")).to have_text "Search for an academy trust or federation"

        autocomplete_group_step

        expect(find("h1.govuk-heading-l")).to have_text "Is this the academy trust or federation you're buying for?"

        expect(values[0]).to have_text "New Academy Trust,"
        expect(values[1]).to have_text "Boundary House Shr, 91 Charter House Street, EC1M 6HR"
      end
    end

    describe "the school confirmation page" do
      before do
        autocomplete_school_step
      end

      it "goes back to the school search page and retains the autocompleted result" do
        click_on "Back"

        expect(page).to have_current_path %r{/procurement-support/search_for_organisation}

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
    end

    describe "the name page" do
      before do
        autocomplete_school_step
        confirm_choice_step
      end

      it "asks for their full name" do
        expect(find("span.govuk-caption-l")).to have_text "About you"
        expect(find("h1.govuk-heading-l")).to have_text "What is your name?"

        expect(page).to have_field "First Name"
        expect(page).to have_field "Last Name"

        expect(page).to have_button "Continue"
      end
    end

    describe "the email address page" do
      before do
        autocomplete_school_step
        confirm_choice_step
        complete_name_step
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
        expect(page).to have_link "Enter an email address", href: "#framework-support-form-email-field-error"
      end
    end

    describe "the message text page" do
      before do
        autocomplete_school_step
        confirm_choice_step
        complete_name_step
        complete_email_step
      end

      it "has the correct attributes" do
        expect(find("span.govuk-caption-l")).to have_text "About your request"
        expect(find("label.govuk-label--l")).to have_text "How can we help?"

        expect(page).to have_field "framework_support_form[message_body]"

        expect(page).to have_button "Continue"
      end
    end

    describe "the procurement amount page", js: true do
      before do
        autocomplete_school_step
        confirm_choice_step
        complete_name_step
        complete_email_step
        complete_help_message_step
      end

      it "has the correct attributes" do
        expect(page).to have_text "About your procurement"
        expect(page).to have_text "Approximately how much will the school be spending on this procurement in total?"

        expect(page).to have_text "This is the approximate amount you'll be spending over the lifetime of the contract. Use the value of a previous or existing contract if you're unsure."
        expect(page).to have_text "We only use this value as a guide to understand your procurement better. We know it can change."

        expect(page).to have_button "Continue"
      end
    end

    describe "the special requirements page", js: true do
      before do
        autocomplete_school_step
        confirm_choice_step
        complete_name_step
        complete_email_step
        complete_help_message_step
        complete_procurement_amount_step
      end

      it "has the correct attributes" do
        expect(page).to have_text "Special requirements"
        expect(page).to have_text "Do you have any special requirements when you communicate or use technology and/or online services?"

        expect(page).to have_text "We will be contacting you by email or video call. Tell us about any adjustments we can make, so that we can help and interact with you in the best way possible."

        expect(page).to have_unchecked_field "Yes"
        expect(page).to have_field "What are your requirements?"
        expect(page).to have_unchecked_field "No"

        expect(page).to have_button "Continue"
      end
    end
  end

  context "when selecting a group or trust", js: true do
    before do
      choose "An academy trust or federation"
      click_continue
    end

    describe "the search for a group page" do
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
    end

    describe "the group confirmation page" do
      before do
        autocomplete_group_step
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
