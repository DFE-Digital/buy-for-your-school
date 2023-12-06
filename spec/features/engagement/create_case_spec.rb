RSpec.feature "Create case", js: true do
  include_context "with an engagement agent"

  before do
    define_basic_categories
    define_basic_queries

    create(:support_category, :with_sub_category)
    create(:support_organisation, name: "Hillside School", urn: "000001", local_authority: { "code": "001", "name": "Timbuktoo" })

    visit "/engagement/cases"
    click_button "Create a new case"
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

      expect(find("h1.govuk-heading-l")).to have_text "Check your answers before creating a new case"
    end

    it "allows you to change answers" do
      complete_valid_form

      within "#changeSchool" do
        click_link "Change"
      end

      fill_in "case_request[first_name]", with: "new_first_name"
      click_on "Save and continue"

      within "#fullName" do
        expect(page).to have_text "new_first_name last_name"
      end
    end

    context "when selecting a MAT" do
      let(:group_type) { create(:support_establishment_group_type, code: 6) }
      let(:group) { create(:support_establishment_group, name: "Group 1", establishment_group_type: group_type, uid: "123") }

      before do
        create_list(:support_organisation, 3, trust_code: group.uid)
      end

      it "sets the group as the case organisation and participating schools", flaky: true do
        select_organisation "Group 1"
        valid_form_data_without_organisation
        click_on "Save and continue"
        check "School #1"
        check "School #2"
        click_on "Save"
        click_on "Create case"
        expect(Support::Case.last.organisation).to eq(group)
        expect(Support::Case.last.participating_schools.pluck(:name)).to match_array(["School #1", "School #2"])
      end
    end

    it "allows case to be created" do
      complete_valid_form

      click_on "Create case"

      within("div#my-cases") do
        verify_case_panel
      end

      within("div#all-cases") do
        verify_case_panel
      end
    end

    def table_cell(row, column) = ".single-row:nth-child(#{row}) .govuk-table__cell:nth-child(#{column})"
  end

  def valid_form_data_without_organisation
    fill_in "case_request[first_name]", with: "first_name"
    fill_in "case_request[last_name]", with: "last_name"
    fill_in "case_request[email]", with: "test@example.com"
    fill_in "case_request[phone_number]", with: "0778974653"
    choose "Non-DfE newsletter" # case origin
    choose "Procurement" # request type
    select "Other (General)", from: "select_request_details_category_id"
    find("#request_details_other_category_text").set("Other Category Details")
    fill_in "case_request[request_text]", with: "This is a request"
    fill_in "case_request[procurement_amount]", with: "45.22"
  end

  def valid_form_data
    select_organisation "Hillside School"
    valid_form_data_without_organisation
  end

  def complete_valid_form
    valid_form_data
    click_on "Save and continue"
  end

  def verify_case_panel
    expect(page).to have_css(".govuk-summary-card#case-panel-000001")

    within ".govuk-summary-card#case-panel-000001" do
      within ".govuk-summary-card__title" do
        expect(page).to have_content("000001 Hillside School")
      end

      within ".govuk-summary-list__row", text: "Created by" do
        expect(page).to have_content("Procurement Specialist")
      end

      within ".govuk-summary-list__row", text: "Sub-category" do
        expect(page).to have_content("Other (General)")
      end

      within ".govuk-summary-list__row", text: "Case value" do
        expect(page).to have_content("£45.22")
      end

      within ".govuk-summary-list__row", text: "Number of schools" do
        expect(page).to have_content("1")
      end

      within ".govuk-summary-list__row", text: "LEA" do
        expect(page).to have_content("Timbuktoo")
      end

      within ".govuk-summary-list__row", text: "Stage" do
        expect(page).to have_content("Not specified")
      end

      within ".govuk-summary-list__row", text: "Status" do
        expect(page).to have_content("New")
      end

      within ".govuk-summary-list__row", text: "Level" do
        expect(page).to have_content("1")
      end

      within ".govuk-summary-list__row", text: "Date created" do
        expect(page).to have_content(Time.zone.now.strftime("%d %b %Y"))
      end

      within ".govuk-summary-list__row", text: "Updated" do
        expect(page.text).to end_with("1 min ago").or end_with("moments ago") # Catches edge case where form is submitted at 59s and view renders into the next minute
      end
    end
  end

  def select_organisation(term)
    fill_in "Organisation name", with: term
    sleep 0.5
    find(".autocomplete__option", text: term)&.click
  end
end
