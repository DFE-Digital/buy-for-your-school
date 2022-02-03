RSpec.feature "Create case" do
  include_context "with an agent"

  before do
    create(:support_category, :with_sub_category)
    create(:support_organisation, name: "Hillside School", urn: "000001")

    click_button "Agent Login"
    visit "/support/cases/new"
  end

  describe "Back link" do
    it_behaves_like "breadcrumb_back_link" do
      let(:url) { "/support/cases" }
    end
  end

  it "shows the create case heading" do
    expect(find("h1.govuk-heading-l")).to have_text "Create a new case"
  end

  it "shows the hub case information heading" do
    expect(find("h2.govuk-heading-l")).to have_text "Hub migration case information"
  end

  context "with invalid data" do
    it "validates the school urn" do
      valid_form_data
      fill_in "create_case_form[school_urn]", with: "23452"

      click_on "Save and continue"

      within "div.govuk-error-summary" do
        expect(page).to have_text "Invalid school URN"
      end
    end
  end

  context "with valid data" do
    it "previews a complete form with valid data" do
      valid_form_data

      click_on "Save and continue"

      expect(page).to have_current_path "/support/cases/preview"
      expect(find("h1.govuk-heading-l")).to have_text "Check your answers before creating a new case"
      expect(find("#changeCategory").sibling("dd")).to have_text "Not applicable"
    end

    it "allows you to change answers" do
      complete_valid_form

      within "#changeSchool" do
        click_button "Change"
      end

      fill_in "create_case_form[first_name]", with: "new_first_name"
      click_on "Save and continue"

      within "#fullName" do
        expect(page).to have_text "new_first_name last_name"
      end
    end

    context "when no identification number provided" do
      it "doesnt show case type" do
        complete_valid_form
        expect(find("dd.case-type")).to have_text ""
      end
    end

    context "when south west identification number provided" do
      it "doesnt show case type" do
        valid_form_data
        fill_in "create_case_form[hub_case_ref]", with: "CE-11111"
        click_on "Save and continue"

        expect(find("dd.case-type")).to have_text "South west hub case"
      end
    end

    it "allows case to be created" do
      complete_valid_form

      click_on "Create case"
      expect(find("h3#case-ref")).to have_text "000001"
    end

    context "with valid data" do
      it "validates a phone number (valid 0)" do
        valid_form_data
        fill_in "create_case_form[phone_number]", with: "01234567890"
        click_on "Save and continue"
        click_on "Create case"
        expect(find("h3#case-ref")).to have_text "000001"
      end

      it "validates a phone number (valid +44)" do
        valid_form_data
        fill_in "create_case_form[phone_number]", with: "+441234567890"
        click_on "Save and continue"
        click_on "Create case"
        expect(find("h3#case-ref")).to have_text "000001"
      end
    end

    context "with invalid data it validates a phone number" do
      it "(min size)" do
        fill_in "create_case_form[phone_number]", with: "0123"
        click_on "Save and continue"
        expect(find("h2.govuk-error-summary__title")).to have_text "There is a problem"
        expect(page).to have_link "Phone number must have no spaces and begin with a 0 or +44, with a minimum of 10 and maximum 12 digits", href: "#create-case-form-phone-number-field-error"
        within "div.govuk-error-summary__body" do
          expect(page).to have_text "Phone number must have no spaces and begin with a 0 or +44, with a minimum of 10 and maximum 12 digits"
        end
      end

      it "(international code)" do
        fill_in "create_case_form[phone_number]", with: "+3551234567"
        click_on "Save and continue"
        expect(find("h2.govuk-error-summary__title")).to have_text "There is a problem"
        expect(page).to have_link "Phone number must have no spaces and begin with a 0 or +44, with a minimum of 10 and maximum 12 digits", href: "#create-case-form-phone-number-field-error"
        within "div.govuk-error-summary__body" do
          expect(page).to have_text "Phone number must have no spaces and begin with a 0 or +44, with a minimum of 10 and maximum 12 digits"
        end
      end

      it "(white space)" do
        fill_in "create_case_form[phone_number]", with: "0208 590 1465"
        click_on "Save and continue"
        expect(find("h2.govuk-error-summary__title")).to have_text "There is a problem"
        expect(page).to have_link "Phone number must have no spaces and begin with a 0 or +44, with a minimum of 10 and maximum 12 digits", href: "#create-case-form-phone-number-field-error"
        within "div.govuk-error-summary__body" do
          expect(page).to have_text "Phone number must have no spaces and begin with a 0 or +44, with a minimum of 10 and maximum 12 digits"
        end
      end

      it "(leading zero)" do
        fill_in "create_case_form[phone_number]", with: "11234567890"
        click_on "Save and continue"
        expect(find("h2.govuk-error-summary__title")).to have_text "There is a problem"
        expect(page).to have_link "Phone number must have no spaces and begin with a 0 or +44, with a minimum of 10 and maximum 12 digits", href: "#create-case-form-phone-number-field-error"
        within "div.govuk-error-summary__body" do
          expect(page).to have_text "Phone number must have no spaces and begin with a 0 or +44, with a minimum of 10 and maximum 12 digits"
        end
      end

      it "(only numbers)" do
        fill_in "create_case_form[phone_number]", with: "0123456789x"
        click_on "Save and continue"
        expect(find("h2.govuk-error-summary__title")).to have_text "There is a problem"
        expect(page).to have_link "Phone number must have no spaces and begin with a 0 or +44, with a minimum of 10 and maximum 12 digits", href: "#create-case-form-phone-number-field-error"
        within "div.govuk-error-summary__body" do
          expect(page).to have_text "Phone number must have no spaces and begin with a 0 or +44, with a minimum of 10 and maximum 12 digits"
        end
      end

      it "(max size)" do
        fill_in "create_case_form[phone_number]", with: "+4412345678901343"
        click_on "Save and continue"
        expect(find("h2.govuk-error-summary__title")).to have_text "There is a problem"
        expect(page).to have_link "Phone number can not have more than 12 digits", href: "#create-case-form-phone-number-field-error"
        within "div.govuk-error-summary__body" do
          expect(page).to have_text "Phone number can not have more than 12 digits"
        end
      end
    end
  end

  context "with unchosen request type" do
    it "only raises missing request type error" do
      click_on "Save and continue"

      within "div.govuk-error-summary" do
        expect(page).to have_text "Select the request type"
        expect(page).to_not have_text "Please select a procurement category"
      end
    end
  end

  context "with request type 'yes' and no procurement category selected" do
    it "only raises missing procurement category error" do
      choose "Yes"
      click_on "Save and continue"

      within "div.govuk-error-summary" do
        expect(page).to_not have_text "Select the request type"
        expect(page).to have_text "Please select a procurement category"
      end
    end
  end

  context "with request type 'yes' and procurement category selected", js: true do
    it "raises no errors" do
      choose "Yes"
      find("#create-case-form-category-id-field").find(:option, 'Catering').select_option
      click_on "Save and continue"
      within "div.govuk-error-summary" do
        expect(page).to_not have_text "Select the request type"
        expect(page).to_not have_text "Please select a procurement category"
      end
    end
  end

  def valid_form_data
    fill_in "create_case_form[school_urn]", with: "000001"
    fill_in "create_case_form[first_name]", with: "first_name"
    fill_in "create_case_form[last_name]", with: "last_name"
    fill_in "create_case_form[email]", with: "test@example.com"
    fill_in "create_case_form[phone_number]", with: "0778974653"
    choose "No" # request type
  end

  def complete_valid_form
    valid_form_data
    click_on "Save and continue"
  end
end
