require "rails_helper"

describe "Agent can change case summary", :js do
  include_context "with an agent"

  let(:support_case) { create(:support_case, support_level: :L1, value: nil, source: "nw_hub", project: "test project", category: gas_category, procurement_stage: need_stage) }

  before do
    define_basic_categories
    define_basic_queries
    define_basic_procurement_stages

    visit support_case_path(support_case)
    click_on "Case details"
    within "h3", text: "Case summary - change" do
      click_link "change"
    end
  end

  context "when changing the support level, procurement stage, case value, case project, and next key date" do
    before do
      choose "4 - DfE buying through a framework"
      select "Tender preparation", from: "Stage"
      fill_in "Case value or estimated contract value (optional)", with: "123.32"
      select "Please select", from: "Case project"
      fill_in "Day", with: "10"
      fill_in "Month", with: "08"
      fill_in "Year", with: "2023"
      fill_in "Description of next key date", with: "Key event"
      click_button "Continue"
      click_button "Save"
      sleep 0.5
    end

    it "persists the changes" do
      expect(support_case.reload.support_level).to eq("L4")
      expect(support_case.reload.procurement_stage.key).to eq("tender_preparation")
      expect(support_case.reload.value).to eq(123.32)
      expect(support_case.reload.source).to eq("nw_hub")
      expect(support_case.reload.project).to eq(nil)
      expect(support_case.reload.next_key_date).to eq(Date.parse("2023-08-10"))
      expect(support_case.reload.next_key_date_description).to eq("Key event")
    end
  end

  describe "Agent changes from procurement category to query" do
    before do
      choose "Non-procurement"
      select "Other", from: "select_request_details_query_id"
      find("#request_details_other_query_text").set("Other Query Details")
      click_continue
    end

    it "allows the user to check their answers" do
      within ".govuk-summary-list__row", text: "Query" do
        expect(page).to have_content("Other - Other Query Details")
      end
    end

    describe "submitting results" do
      it "shows the new category in case details" do
        click_button "Save"

        within ".govuk-summary-list__row", text: "Query" do
          expect(page).to have_content("Other - Other Query Details")
        end
      end
    end
  end

  describe "Agent can add a new project" do
    before do
      select "Add new project", from: "Case project"
      find("#new_project_text").set("brand new project")
      click_continue
    end

    it "allows the user to check their answers" do
      within ".govuk-summary-list__row", text: "Project" do
        expect(page).to have_content("brand new project")
      end
    end

    describe "submitting results" do
      it "shows the new project in case details" do
        click_button "Save"

        within ".govuk-summary-list__row", text: "Project" do
          expect(page).to have_content("brand new project")
        end
      end
    end
  end

  context "when changing the support level to L6 and procurement stage to Enquiry, then case status to be on hold" do
    before do
      support_case.update!(source: :energy_onboarding, category: dfe_energy_for_schools_service_category)
      support_case.reload
      choose "6 - DfE Energy for Schools support case"
      page.execute_script("document.querySelector('#case-summary-procurement-stage-id-field').value = '#{enquiry_stage.id}';")
      select "Please select", from: "Case project"
      fill_in "Day", with: "10"
      fill_in "Month", with: "08"
      fill_in "Year", with: "2023"
      fill_in "Description of next key date", with: "Key event"
      click_button "Continue"
      click_button "Save"
      sleep 0.5
    end

    it "persists the changes" do
      expect(support_case.reload.support_level).to eq("L6")
      expect(support_case.reload.state).to eq("on_hold")
    end
  end

  context "when case with a sub-category of ‘DfE Energy for Schools service’" do
    let!(:energy_case) { create(:support_case, support_level: :L7, value: nil, source: :energy_onboarding, project: "test project", category: dfe_energy_for_schools_service_category, procurement_stage: onboarding_form_stage) }
    let!(:onboarding_case) { create(:onboarding_case, support_case: energy_case) }

    before do
      visit edit_support_case_summary_path(energy_case)
    end

    def expect_fields_disabled(fields)
      fields.each do |field|
        expect(page.find(field)["disabled"]).to eq("true")
      end
    end

    it "request type, case level and stage cannot be changed for an un-submitted Onboarding case" do
      expect(page).to have_content("Update case summary")
      expect(energy_case.energy_onboarding_case?).to eq(true)
      expect(energy_case.reload.source).to eq("energy_onboarding")

      selected_option = page.find("#select_request_details_category_id").find("option[selected]")
      expect(selected_option.text).to eq("DfE Energy for Schools service")

      disabled_fields = [
        "#case-summary-request-type-true-field",
        "#select_request_details_category_id",
        "#case-summary-request-type-field",
        "#case-summary-support-level-l1-field",
        "#case-summary-support-level-l2-field",
        "#case-summary-support-level-l3-field",
        "#case-summary-support-level-l4-field",
        "#case-summary-support-level-l5-field",
        "#case-summary-support-level-l6-field",
        "#case-summary-support-level-l7-field",
        "#case-summary-procurement-stage-id-field",
      ]
      expect_fields_disabled(disabled_fields)
    end

    it "request type and case level cannot be changed and stage can be change for an submitted Onboarding case" do
      onboarding_case.update!(submitted_at: Time.current)
      visit edit_support_case_summary_path(energy_case)

      disabled_fields = [
        "#case-summary-request-type-true-field",
        "#select_request_details_category_id",
        "#case-summary-request-type-field",
        "#case-summary-support-level-l1-field",
        "#case-summary-support-level-l2-field",
        "#case-summary-support-level-l3-field",
        "#case-summary-support-level-l4-field",
        "#case-summary-support-level-l5-field",
        "#case-summary-support-level-l6-field",
        "#case-summary-support-level-l7-field",
      ]
      expect_fields_disabled(disabled_fields)

      expect(page.find("#case-summary-procurement-stage-id-field")["disabled"]).to eq("false")
    end

    it "show only onboarding stages" do
      onboarding_case.update!(submitted_at: Time.current)

      select_box = page.find("#case-summary-procurement-stage-id-field")
      option_group_6 = select_box.all("optgroup").find { |group| group[:label] == "STAGE 6" }
      option_group_1 = select_box.all("optgroup").find { |group| group[:label] == "STAGE 1" }
      expect(option_group_6).not_to be_nil
      expect(option_group_1).to be_nil
    end
  end
end
