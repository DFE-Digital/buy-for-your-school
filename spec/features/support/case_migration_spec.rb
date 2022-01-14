RSpec.feature "Case summary" do
  include_context "with an agent"

  before do
    create(:support_category, :with_sub_category)
    create(:support_organisation, name: "Hillside School", urn: "000001")

    click_button "Agent Login"
    visit "/support/cases/migrations/hub-case/new"
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
    it "validates the presence of the first name" do
      valid_form_data
      fill_in "case_hub_migration_form[first_name]", with: ""

      click_on "Save and continue"

      within "div.govuk-error-summary" do
        expect(page).to have_text "First name is missing"
      end
    end

    it "validates the school urn" do
      valid_form_data
      fill_in "case_hub_migration_form[school_urn]", with: "23452"

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

      expect(page).to have_current_path "/support/cases/migrations/hub-case/preview"
      expect(find("h1.govuk-heading-l")).to have_text "Check your answers before creating a new case"
    end

    it "allows you to change answers" do
      complete_valid_form

      within "#changeSchool" do
        click_button "Change"
      end

      fill_in "case_hub_migration_form[first_name]", with: "new_first_name"
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
        fill_in "case_hub_migration_form[hub_case_ref]", with: "CE-11111"
        click_on "Save and continue"

        expect(find("dd.case-type")).to have_text "South west hub case"
      end
    end

    it "allows case to be created" do
      complete_valid_form

      click_on "Create case"
      expect(find("h3#case-ref")).to have_text "000001"
    end
  end

  def valid_form_data
    fill_in "case_hub_migration_form[school_urn]", with: "000001"
    fill_in "case_hub_migration_form[first_name]", with: "first_name"
    fill_in "case_hub_migration_form[last_name]", with: "last_name"
    fill_in "case_hub_migration_form[email]", with: "test@example.com"
    fill_in "case_hub_migration_form[phone_number]", with: "0778974653"
  end

  def complete_valid_form
    valid_form_data
    click_on "Save and continue"
  end
end
