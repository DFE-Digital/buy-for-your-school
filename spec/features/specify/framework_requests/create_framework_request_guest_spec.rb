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
    select_autocomplete_option("Greendale Academy for Bright Sparks")
    click_continue
  end

  def autocomplete_group_step
    # missing last digit
    fill_in "Enter name, Unique group identifier (UID) or UK Provider Reference Number (UKPRN)", with: "231"
    select_autocomplete_option("Testing Multi Academy Trust")
    click_continue
  end

  def complete_confirm_group_step
    choose "Yes"
    click_continue
  end

  def complete_help_message_step
    fill_in "framework_support_form[message_body]", with: "I have a problem"
    click_continue
  end

  def complete_category_step
    choose "A category"
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
    create(:request_for_help_category, title: "A category", slug: "a", flow: :goods)

    visit "/procurement-support/sign_in"
    choose "No, continue without a DfE Sign-in account"
    click_continue
  end

  describe "the organisation type choice page" do
    it "asks for school or group" do
      expect(find("legend.govuk-fieldset__legend--l")).to have_text "What type of organisation are you buying for?"
    end
  end

  context "when selecting a single school", :js do
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
          expect(page).to have_text "Private, voluntary-aided and independent early years providers, and institutions which only have pupils aged 16 years and above, are not eligible for this service."

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

        expect(values[0]).to have_text "Testing Multi Academy Trust"
        expect(values[1]).to have_text "Boundary House Shr, 91 Charter House Street, EC1M 6HR"
      end

      it "doesn't include archived schools in the dropdown" do
        fill_in "Enter the name, postcode or unique reference number (URN) of your school", with: "10025"
        expect(page).to have_text "Greendale Academy for Bright Sparks"
        expect(page).not_to have_text "Archived Org"
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
        expect(page).to have_text "About you"
        expect(page).to have_text "What is your email address?"

        expect(page).to have_text "Use your school email address. We will only use this to contact you about your request."

        expect(page).to have_button "Continue"
      end

      it "validates their email" do
        click_continue

        expect(find("h2.govuk-error-summary__title")).to have_text "There is a problem"
        expect(page).to have_link "Enter an email address", href: "#framework-support-form-email-field-error"
      end

      it "doesn't allow non-school email addresses" do
        fill_in "framework_support_form[email]", with: "test@gmail.com"
        click_continue

        expect(find("h2.govuk-error-summary__title")).to have_text "There is a problem"
        expect(page).to have_link "Enter a school email address in the correct format, like name@example.sch.uk. You cannot use a personal email address such as @gmail.com", href: "#framework-support-form-email-field-error"

        fill_in "framework_support_form[email]", with: "test@Gmail.com"
        click_continue

        expect(find("h2.govuk-error-summary__title")).to have_text "There is a problem"
        expect(page).to have_link "Enter a school email address in the correct format, like name@example.sch.uk. You cannot use a personal email address such as @Gmail.com", href: "#framework-support-form-email-field-error"

        fill_in "framework_support_form[email]", with: "test@sky.example"
        click_continue

        expect(find("h2.govuk-error-summary__title")).to have_text "There is a problem"
        expect(page).to have_link "Enter a school email address in the correct format, like name@example.sch.uk. You cannot use a personal email address such as @sky.example", href: "#framework-support-form-email-field-error"
      end

      it "allows school email addresses" do
        fill_in "framework_support_form[email]", with: "test@sky.learnmat.uk"
        click_continue

        expect(page).to have_text "What type of goods or service do you need?"

        click_link "Back"
        fill_in "framework_support_form[email]", with: "test@sch.uk"
        click_continue

        expect(page).to have_text "What type of goods or service do you need?"
      end
    end

    describe "the categories page" do
      before do
        autocomplete_school_step
        confirm_choice_step
        complete_name_step
        complete_email_step
      end

      it "has the correct attributes" do
        expect(page).to have_title "What type of goods or service do you need?"
      end
    end

    describe "the message text page" do
      before do
        autocomplete_school_step
        confirm_choice_step
        complete_name_step
        complete_email_step
        complete_category_step
        complete_procurement_amount_step
      end

      it "has the correct attributes" do
        expect(find("span.govuk-caption-l")).to have_text "About your request"
        expect(find("label.govuk-label--l")).to have_text "How can we help?"

        expect(page).to have_field "framework_support_form[message_body]"

        expect(page).to have_button "Continue"
      end
    end

    describe "the procurement amount page", :js do
      before do
        autocomplete_school_step
        confirm_choice_step
        complete_name_step
        complete_email_step
        complete_category_step
      end

      it "has the correct attributes" do
        expect(page).to have_text "About your procurement"
        expect(page).to have_text "Approximately how much will the school be spending on this procurement in total?"

        expect(page).to have_text "This is the approximate amount you'll be spending over the lifetime of the contract. Use the value of a previous or existing contract if you're unsure."
        expect(page).to have_text "We only use this value as a guide to understand your procurement better. We know it can change."

        expect(page).to have_button "Continue"
      end
    end

    describe "the special requirements page", :js do
      before do
        autocomplete_school_step
        confirm_choice_step
        complete_name_step
        complete_email_step
        complete_category_step
        complete_procurement_amount_step
        complete_help_message_step
      end

      it "has the correct attributes" do
        expect(page).to have_text "Accessibility"
        expect(page).to have_text "Do you have any access needs that we need to be aware of when we contact you?"

        expect(page).to have_text "We’ll contact you by email first. If we need more information we’ll arrange a video call with you later. Let us know if either of these need to be made accessible to you and how you’d like us to do that."

        expect(page).to have_unchecked_field "Yes"
        expect(page).to have_field "Tell us about your access needs"
        expect(page).to have_unchecked_field "No"

        expect(page).to have_button "Continue"
      end
    end
  end

  context "when selecting a group or trust", :js do
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
          expect(page).to have_text "Private, voluntary-aided and independent early years providers, and institutions which only have pupils aged 16 years and above, are not eligible for this service."

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

      it "doesn't include archived establishment groups in the dropdown", :flaky do
        fill_in "Enter name, Unique group identifier (UID) or UK Provider Reference Number (UKPRN)", with: "10025"
        expect(page).to have_text "Testing Multi Academy Trust"
        expect(page).not_to have_text "Archived Group"
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
        expect(values[0]).to have_text "Testing Multi Academy Trust"

        expect(keys[1]).to have_text "Address"
        expect(values[1]).to have_text "Boundary House Shr, 91 Charter House Street, EC1M 6HR"

        expect(keys[2]).to have_text "Group type"
        expect(values[2]).to have_text "Multi-academy Trust"

        expect(keys[3]).to have_text "ID"
        expect(values[3]).to have_text "UID: 2314 UKPRN: 1010010"

        expect(page).to have_unchecked_field "Yes"
        expect(page).to have_unchecked_field "No, I need to choose another academy trust or federation"
        expect(page).to have_button "Continue"
      end
    end

    describe "multischool picker" do
      before do
        autocomplete_group_step
        complete_confirm_group_step
      end

      describe "allows to select and confirm schools in the group" do
        it "does not show an archived school as an option to select" do
          expect(page).to have_text "0 of 2 schools"
          expect(page).not_to have_text "Archived Org"
        end

        it "saves selected schools" do
          check "Specialist School for Testing"
          check "Greendale Academy for Bright Sparks"
          click_continue

          choose "Yes"
          click_continue

          expect(FrameworkRequest.first.school_urns).to match_array(%w[100253 100254])
        end
      end
    end
  end
end
