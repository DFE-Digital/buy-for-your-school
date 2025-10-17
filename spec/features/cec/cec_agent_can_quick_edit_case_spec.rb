require "rails_helper"

describe "Agent can quick edit a case", :js do
  include_context "with a cec agent"

  let!(:dfe_energy_category) { create(:support_category, title: "DfE Energy for Schools service") }
  let!(:energy_stage) { create(:support_procurement_stage, key: "onboarding_form", title: "Onboarding form", stage: "6") }
  let!(:support_case) { create(:support_case, ref: "000001", agent:, category: dfe_energy_category, support_level: "L6", source: :energy_onboarding, procurement_stage: energy_stage) }

  before do
    visit cec_onboarding_cases_path(anchor: "my-cases")
    within("#my-cases") { click_link "Quick edit" }
  end

  context "when changing the note, next key date, and 'with school' flag" do
    before do
      fill_in "Add a note to case 000001", with: "New note"
      fill_in "Day", with: "10"
      fill_in "Month", with: "08"
      fill_in "Year", with: "2026"
      fill_in "Description of next key date", with: "Key event"
      choose "Yes"
      click_button "Save"
    end

    it "persists the changes" do
      expect(support_case.reload.support_level).to eq("L6")
      expect(support_case.reload.next_key_date).to eq(Date.parse("2026-08-10"))
      expect(support_case.reload.next_key_date_description).to eq("Key event")
      expect(support_case.reload.with_school).to eq(true)
    end
  end
end
