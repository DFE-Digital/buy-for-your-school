require "rails_helper"

describe "Agent can quick edit a framework evaluation", :js do
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
      choose "In progress"
      click_button "Save"
    end

    it "persists the changes" do
      framework_evaluation.reload
      expect(framework_evaluation.latest_note.body).to eq("New note")
      expect(framework_evaluation.next_key_date).to eq(Date.parse("2023-08-10"))
      expect(framework_evaluation.next_key_date_description).to eq("Key event")
      expect(framework_evaluation.status).to eq("in_progress")
    end
  end
end
