require "rails_helper"

describe "Agent can quick edit a framework evaluation", js: true do
  include_context "with a framework evaluation agent"

  let!(:framework_evaluation) { create(:frameworks_evaluation, reference: "FE1") }

  before do
    visit frameworks_root_path(anchor: "evaluations")
    within("#evaluations") { click_link "Quick edit" }
  end

  context "when changing the note and next key date" do
    before do
      fill_in "Add a note", with: "New note"
      fill_in "Day", with: "10"
      fill_in "Month", with: "08"
      fill_in "Year", with: "2023"
      fill_in "Description of next key date", with: "Key event"
      click_button "Save"
    end

    it "persists the changes" do
      expect(framework_evaluation.latest_note.body).to eq("New note")
      expect(framework_evaluation.reload.next_key_date).to eq(Date.parse("2023-08-10"))
      expect(framework_evaluation.reload.next_key_date_description).to eq("Key event")
    end
  end
end
