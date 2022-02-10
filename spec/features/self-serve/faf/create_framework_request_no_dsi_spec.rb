RSpec.feature "Create a new framework request through non-DSI journey" do
  before do
    create(:support_organisation, :with_address, urn: "100253", name: "School #1", phase: 7, number: "334", ukprn: "4346", establishment_type: create(:support_establishment_type, name: "Community school"))
    create(:support_establishment_group, :with_address, name: "Group #1", establishment_group_type: create(:support_establishment_group_type, name: "Multi-academy Trust"))
    visit "/procurement-support/new"
    choose "No, continue without a DfE Sign-in account"
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
    before do
      choose "A single school"
      click_continue
    end

    describe "what is your name page" do
      it "has a back link to step 2" do
        click_on "Back"
        expect(page).to have_current_path "/procurement-support?framework_support_form%5Bback%5D=true&framework_support_form%5Bdsi%5D=false&framework_support_form%5Bgroup%5D=false&framework_support_form%5Bstep%5D=3"
        expect(page).to have_text "What type of organisation are you buying for?"
      end

      it "has the correct attributes" do
        expect(find("span.govuk-caption-l")).to have_text "About you"
        expect(find("h1.govuk-heading-l")).to have_text "What is your name?"

        expect(page).to have_field "First Name"
        expect(page).to have_field "Last Name"

        expect(page).to have_button "Continue"
      end

      it "raises a validation error when nothing entered" do
        click_continue
        expect(find("h2.govuk-error-summary__title")).to have_text "There is a problem"
        expect(page).to have_link "Enter your first name", href: "#framework-support-form-first-name-field-error"
        expect(all(".govuk-error-message")[0]).to have_text "Enter your first name"
        expect(page).to have_link "Enter your last name", href: "#framework-support-form-last-name-field-error"
        expect(all(".govuk-error-message")[1]).to have_text "Enter your last name"
      end
    end

    describe "what is your email address page" do
      before do
        complete_name_step
      end

      it "has a back link to step 3" do
        click_on "Back"
        expect(page).to have_current_path "/procurement-support?framework_support_form%5Bback%5D=true&framework_support_form%5Bdsi%5D=false&framework_support_form%5Bfirst_name%5D=Test&framework_support_form%5Bgroup%5D=false&framework_support_form%5Blast_name%5D=User&framework_support_form%5Bstep%5D=4"
        expect(page).to have_text "What is your name?"
      end

      it "has the correct attributes" do
        expect(find("span.govuk-caption-l")).to have_text "About you"
        expect(find("label.govuk-label--l")).to have_text "What is your email address?"

        expect(page).to have_field "We will only use this to contact you about your request."

        expect(page).to have_button "Continue"
      end

      it "validates email field" do
        click_continue
        expect(find("h2.govuk-error-summary__title")).to have_text "There is a problem"
        expect(page).to have_link "Enter an email in the correct format. For example, 'someone@school.sch.uk'.", href: "#framework-support-form-email-field-error"
        expect(find("#framework-support-form-email-error")).to have_text "Enter an email in the correct format. For example, 'someone@school.sch.uk'."
      end
    end

    describe "search for a school page" do
      before do
        complete_name_step
        complete_email_step
      end

      it "has a back link to step 4" do
        click_on "Back"
        expect(page).to have_current_path "/procurement-support?framework_support_form%5Bback%5D=true&framework_support_form%5Bdsi%5D=false&framework_support_form%5Bemail%5D=test%40email.com&framework_support_form%5Bfirst_name%5D=Test&framework_support_form%5Bgroup%5D=false&framework_support_form%5Blast_name%5D=User&framework_support_form%5Bstep%5D=5"
        expect(page).to have_text "What is your email address?"
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
          expect(page).to have_link "Search for an academy trust or federation"
        end

        expect(page).to have_button "Continue"
      end

      it "has a link to the group search page" do
        find("span", text: "Can't find it?").click
        click_on "Search for an academy trust or federation"
        expect(page).to have_current_path "/procurement-support?framework_support_form%5Bback%5D=true&framework_support_form%5Bdsi%5D=false&framework_support_form%5Bemail%5D=test%40email.com&framework_support_form%5Bfirst_name%5D=Test&framework_support_form%5Bgroup%5D=true&framework_support_form%5Blast_name%5D=User&framework_support_form%5Bstep%5D=6"
        expect(page).to have_text "Search for a group or trust"
      end

      it "validates school field" do
        click_continue
        expect(find("h2.govuk-error-summary__title")).to have_text "There is a problem"
        expect(page).to have_link "Select the school you want help buying for", href: "#framework-support-form-school-urn-field-error"
      end
    end

    describe "school details page" do
      before do
        complete_name_step
        complete_email_step
        complete_school_step
      end

      it "has a back link to step 5" do
        click_on "Back"
        expect(page).to have_current_path "/procurement-support?framework_support_form%5Bback%5D=true&framework_support_form%5Bdsi%5D=false&framework_support_form%5Bemail%5D=test%40email.com&framework_support_form%5Bfirst_name%5D=Test&framework_support_form%5Bgroup%5D=false&framework_support_form%5Bgroup_uid%5D=&framework_support_form%5Blast_name%5D=User&framework_support_form%5Bschool_urn%5D=100253+-+School+%231&framework_support_form%5Bstep%5D=6"
        expect(page).to have_text "Search for your school"
      end

      it "has the correct attributes" do
        expect(find("span.govuk-caption-l")).to have_text "About your school"
        expect(find("h1.govuk-heading-l")).to have_text "Is this the school you're buying for?"
        within("dl.govuk-summary-list") do
          expect(all("dt.govuk-summary-list__key")[0]).to have_text "Name and Address"
          expect(all("dd.govuk-summary-list__value")[0]).to have_text "School #1, St James's Passage, Duke's Place, EC3A 5DE"

          expect(all("dt.govuk-summary-list__key")[1]).to have_text "Local authority"
          expect(all("dd.govuk-summary-list__value")[1]).to have_text "Camden"

          expect(all("dt.govuk-summary-list__key")[2]).to have_text "Headteacher / Principal"
          expect(all("dd.govuk-summary-list__value")[2]).to have_text "Ms Head Teacher"

          expect(all("dt.govuk-summary-list__key")[3]).to have_text "Phase of education"
          expect(all("dd.govuk-summary-list__value")[3]).to have_text "All through"

          expect(all("dt.govuk-summary-list__key")[4]).to have_text "School type"
          expect(all("dd.govuk-summary-list__value")[4]).to have_text "Community school"

          expect(all("dt.govuk-summary-list__key")[5]).to have_text "ID"
          expect(all("dd.govuk-summary-list__value")[5]).to have_text "URN: 100253 DfE number: 334 UKPRN: 4346"
        end
        expect(page).to have_unchecked_field "Yes"
        expect(page).to have_unchecked_field "No, I need to choose another school"
        expect(page).to have_button "Continue"
      end

      it "goes back to step 5 if user chooses no" do
        choose "No, I need to choose another school"
        click_continue
        expect(page).to have_current_path "/procurement-support?framework_support_form%5Bback%5D=true&framework_support_form%5Bdsi%5D=false&framework_support_form%5Bemail%5D=test%40email.com&framework_support_form%5Bfirst_name%5D=Test&framework_support_form%5Bgroup%5D=false&framework_support_form%5Bgroup_uid%5D=&framework_support_form%5Blast_name%5D=User&framework_support_form%5Bschool_urn%5D=100253+-+School+%231&framework_support_form%5Bstep%5D=6"
        expect(page).to have_text "Search for your school"
      end
    end

    describe "how can we help page" do
      before do
        complete_name_step
        complete_email_step
        complete_school_step
        complete_school_details_step
      end

      it "has a back link to step 6" do
        click_on "Back"
        expect(page).to have_current_path "/procurement-support?framework_support_form%5Bback%5D=true&framework_support_form%5Bdsi%5D=false&framework_support_form%5Bemail%5D=test%40email.com&framework_support_form%5Bfirst_name%5D=Test&framework_support_form%5Bgroup%5D=false&framework_support_form%5Bgroup_uid%5D=&framework_support_form%5Blast_name%5D=User&framework_support_form%5Bschool_urn%5D=100253+-+School+%231&framework_support_form%5Bstep%5D=7"
        expect(page).to have_text "Is this the school you're buying for?"
      end

      it "has the correct attributes" do
        expect(find("span.govuk-caption-l")).to have_text "About your request"
        expect(find("label.govuk-label--l")).to have_text "How can we help?"

        expect(find("div.govuk-hint")).to have_text "Briefly describe what advice or guidance you need in a few sentences."
        expect(page).to have_field "framework_support_form[message_body]"

        expect(page).to have_button "Continue"
      end

      it "validates the help message field" do
        click_continue
        expect(find("h2.govuk-error-summary__title")).to have_text "There is a problem"
        expect(page).to have_link "You must tell us how we can help", href: "#framework-support-form-message-body-field-error"
        expect(find("#framework-support-form-message-body-error")).to have_text "Error: You must tell us how we can help"
      end
    end

    describe "send your request page" do
      before do
        complete_name_step
        complete_email_step
        complete_school_step
        complete_school_details_step
        complete_help_message_step
      end

      it "has persisted the request" do
        expect(FrameworkRequest.count).to eq 1
      end

      it "has a back link to step 7" do
        click_on "Back"
        expect(page).to have_current_path "/procurement-support/#{FrameworkRequest.first.id}/edit?step=7"
        expect(page).to have_text "How can we help?"
      end

      it "has the correct attributes" do
        expect(find("h1.govuk-heading-l")).to have_text "Send your request"
        within("dl.govuk-summary-list") do
          expect(all("dt.govuk-summary-list__key")[0]).to have_text "Your name"
          expect(all("dd.govuk-summary-list__value")[0]).to have_text "Test User"
          expect(all("dd.govuk-summary-list__actions")[0]).to have_link "Change"

          expect(all("dt.govuk-summary-list__key")[1]).to have_text "Your email address"
          expect(all("dd.govuk-summary-list__value")[1]).to have_text "test@email.com"
          expect(all("dd.govuk-summary-list__actions")[1]).to have_link "Change"

          expect(all("dt.govuk-summary-list__key")[2]).to have_text "Your school"
          expect(all("dd.govuk-summary-list__value")[2]).to have_text "School #1"
          expect(all("dd.govuk-summary-list__actions")[2]).to have_link "Change"

          expect(all("dt.govuk-summary-list__key")[3]).to have_text "Description of request"
          expect(all("dd.govuk-summary-list__value")[3]).to have_text "I have a problem"
          expect(all("dd.govuk-summary-list__actions")[3]).to have_link "Change"
        end
        expect(find("p.govuk-body")).to have_text "Once you send this request, we will review it and get in touch within 2 working days."
        expect(page).to have_button "Send request"
      end
    end
  end

  context "when group or trust", js: true do
    before do
      choose "A group or trust"
      click_continue
      complete_name_step
      complete_email_step
    end

    describe "search for a group page" do
      it "has a back link to step 4" do
        click_on "Back"
        expect(page).to have_current_path "/procurement-support?framework_support_form%5Bback%5D=true&framework_support_form%5Bdsi%5D=false&framework_support_form%5Bemail%5D=test%40email.com&framework_support_form%5Bfirst_name%5D=Test&framework_support_form%5Bgroup%5D=true&framework_support_form%5Blast_name%5D=User&framework_support_form%5Bstep%5D=5"
        expect(page).to have_text "What is your email address?"
      end

      it "has the correct attributes" do
        expect(find("span.govuk-caption-l")).to have_text "About your school"
        expect(find("h1.govuk-heading-l")).to have_text "Search for a group or trust"

        expect(page).to have_field "Enter name, Unique group identifier (UID) or UK Provider Reference Number (UKPRN)"

        within(find("details.govuk-details")) do
          expect(find("span.govuk-details__summary-text")).to have_text "Can't find it?"
          expect(page).to have_text "This search lists groups and trusts, such as a multi-academy trust or federation. Search for a single school instead."
          expect(page).to have_text "This service is available to all state-funded primary, secondary, special and alternative provision schools with pupils aged between 5 to 16 years old."
          expect(page).to have_text "Private, voluntary-aided and independent early years providers and institutions with pupils aged 16 years and above are not eligible for this service."
          expect(page).to have_link "Search for a single school"
        end

        expect(page).to have_button "Continue"
      end

      it "has a link to the single school search page" do
        find("span", text: "Can't find it?").click
        click_on "Search for a single school"
        expect(page).to have_current_path "/procurement-support?framework_support_form%5Bback%5D=true&framework_support_form%5Bdsi%5D=false&framework_support_form%5Bemail%5D=test%40email.com&framework_support_form%5Bfirst_name%5D=Test&framework_support_form%5Bgroup%5D=false&framework_support_form%5Blast_name%5D=User&framework_support_form%5Bstep%5D=6"
        expect(page).to have_text "Search for your school"
      end

      it "validates group field" do
        click_continue
        expect(find("h2.govuk-error-summary__title")).to have_text "There is a problem"
        expect(page).to have_link "Select the group or trust you want help buying for", href: "#framework-support-form-group-uid-field-error"
      end
    end

    describe "group details page - is this the group or trust?" do
      before do
        complete_group_step
      end

      it "has a back link to step 5" do
        click_on "Back"
        expect(page).to have_current_path "/procurement-support?framework_support_form%5Bback%5D=true&framework_support_form%5Bdsi%5D=false&framework_support_form%5Bemail%5D=test%40email.com&framework_support_form%5Bfirst_name%5D=Test&framework_support_form%5Bgroup%5D=true&framework_support_form%5Bgroup_uid%5D=1234+-+Group+%231&framework_support_form%5Blast_name%5D=User&framework_support_form%5Bschool_urn%5D=&framework_support_form%5Bstep%5D=6"
        expect(page).to have_text "Search for a group or trust"
      end

      it "has the correct attributes" do
        expect(find("span.govuk-caption-l")).to have_text "About your school"
        expect(find("h1.govuk-heading-l")).to have_text "Is this the group or trust you're buying for?"
        within("dl.govuk-summary-list") do
          expect(all("dt.govuk-summary-list__key")[0]).to have_text "Group name"
          expect(all("dd.govuk-summary-list__value")[0]).to have_text "Group #1"

          expect(all("dt.govuk-summary-list__key")[1]).to have_text "Address"
          expect(all("dd.govuk-summary-list__value")[1]).to have_text "Boundary House Shr, 91 Charter House Street, EC1M 6HR"

          expect(all("dt.govuk-summary-list__key")[2]).to have_text "Group type"
          expect(all("dd.govuk-summary-list__value")[2]).to have_text "Multi-academy Trust"

          expect(all("dt.govuk-summary-list__key")[3]).to have_text "ID"
          expect(all("dd.govuk-summary-list__value")[3]).to have_text "UID: 1234 UKPRN: 1010010"
        end
        expect(page).to have_unchecked_field "Yes"
        expect(page).to have_unchecked_field "No, I need to choose another group or trust"
        expect(page).to have_button "Continue"
      end
    end
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

  def complete_school_step
    fill_in "Enter the name, postcode or unique reference number (URN) of your school", with: "Schoo"
    find(".autocomplete__option", text: "School #1").click
    click_continue
  end

  def complete_school_details_step
    choose "Yes"
    click_continue
  end

  def complete_group_step
    fill_in "Enter name, Unique group identifier (UID) or UK Provider Reference Number (UKPRN)", with: "Group"
    find(".autocomplete__option", text: "Group #1").click
    click_continue
  end

  def complete_help_message_step
    fill_in "framework_support_form[message_body]", with: "I have a problem"
    click_continue
  end
end
