RSpec.feature "Create case", js: true do
  include_context "with an engagement agent"

  before do
    define_basic_categories
    define_basic_queries

    create(:support_category, :with_sub_category)
    create(:support_organisation, name: "Hillside School", urn: "000001")

    visit "/engagement/cases/new"
  end

  describe "Back link" do
    it_behaves_like "breadcrumb_back_link" do
      let(:url) { "/engagement/cases" }
    end
  end

  it "shows the create case heading" do
    expect(find("h1.govuk-heading-l")).to have_text "Create a new case"
  end

  context "with valid data" do
    it "previews a complete form with valid data" do
      valid_form_data

      click_on "Save and continue"

      expect(page).to have_current_path "/engagement/cases/preview"
      expect(find("h1.govuk-heading-l")).to have_text "Check your answers before creating a new case"
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

    context "when selecting a group" do
      it "sets the group as the case organisation" do
        group = create(:support_establishment_group, name: "Group 1")
        select_organisation "Group 1"
        valid_form_data_without_organisation
        click_on "Save and continue"
        click_on "Create case"
        expect(Support::Case.last.organisation).to eq(group)
      end
    end

    it "allows case to be created" do
      complete_valid_form

      click_on "Create case"

      within table_cell(1, 1) do
        expect(page).to have_content("000001")
      end

      within table_cell(1, 2) do
        expect(page).to have_content("1")
      end

      within table_cell(1, 3) do
        expect(page).to have_content("Hillside School")
      end

      within table_cell(1, 4) do
        expect(page).to have_content("Other (General)")
      end

      within table_cell(1, 5) do
        expect(page).to have_content("Procurement Specialist")
      end

      within table_cell(1, 6) do
        expect(page).to have_content("45.22")
      end

      within table_cell(1, 7) do
        expect(page).to have_content(Time.zone.now.strftime("%d %b %Y"))
      end
    end

    def table_cell(row, column) = ".single-row:nth-child(#{row}) .govuk-table__cell:nth-child(#{column})"
  end

  def valid_form_data_without_organisation
    fill_in "create_case_form[first_name]", with: "first_name"
    fill_in "create_case_form[last_name]", with: "last_name"
    fill_in "create_case_form[email]", with: "test@example.com"
    fill_in "create_case_form[phone_number]", with: "0778974653"
    choose "Non-DfE newsletter" # case origin
    choose "Procurement" # request type
    select "Other (General)", from: "select_request_details_category_id"
    find("#request_details_other_category_text").set("Other Category Details")
    fill_in "create_case_form[request_text]", with: "This is a request"
    fill_in "create_case_form[procurement_amount]", with: "45.22"
  end

  def valid_form_data
    select_organisation "Hillside School"
    valid_form_data_without_organisation
  end

  def complete_valid_form
    valid_form_data
    click_on "Save and continue"
  end

  def select_organisation(term)
    fill_in "Organisation name", with: term
    sleep 0.5
    find(".autocomplete__option", text: term)&.click
  end
end
