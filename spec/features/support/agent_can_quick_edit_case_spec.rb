require "rails_helper"

describe "Agent can quick edit a case", :js do
  include_context "with an agent"

  let(:support_case) { create(:support_case, ref: "000001", agent:, support_level: :L1, category: gas_category, procurement_stage: need_stage) }

  before do
    define_basic_categories
    define_basic_procurement_stages
    support_case

    visit support_cases_path(anchor: "my-cases")
    within("#my-cases") { click_link "Quick edit" }
  end

  context "when changing the note, support level, stage, next key date, and 'with school' flag" do
    before do
      fill_in "Add a note to case 000001", with: "New note"
      choose "5 - DfE buying by getting quotes or bids"
      select "Tender preparation", from: "Stage"
      fill_in "Day", with: "10"
      fill_in "Month", with: "08"
      fill_in "Year", with: "2023"
      fill_in "Description of next key date", with: "Key event"
      choose "Yes"
      click_button "Save"
    end

    it "persists the changes" do
      expect(support_case.reload.interactions.note.first.body).to eq("New note")
      expect(support_case.reload.support_level).to eq("L5")
      expect(support_case.reload.procurement_stage.key).to eq("tender_preparation")
      expect(support_case.reload.next_key_date).to eq(Date.parse("2023-08-10"))
      expect(support_case.reload.next_key_date_description).to eq("Key event")
      expect(support_case.reload.with_school).to eq(true)
    end
  end

  context "when the case level is 1 to 5" do
    it "Level 6 should be disabled" do
      expect(page.find("#case-quick-edit-support-level-l6-field")[:disabled]).to eq("true")
    end
  end
end
