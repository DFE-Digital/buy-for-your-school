require "rails_helper"

describe "Agent can rename case files" do
  include_context "with an agent"

  let(:support_case) { create(:support_case) }

  before do
    create(:support_case_attachment, case: support_case, custom_name: "text-file.txt")
  end

  it "adds a custom name and description to the file", js: true do
    visit support_case_path(support_case)

    click_link "Files"
    within "#case-files tr", text: "text-file.txt" do
      click_link "Edit"
    end

    fill_in "File name", with: "Procurement Timeline"
    fill_in "Description", with: "Procurement Timeline File Description"
    click_button "Save"

    within "#case-files tr", text: "Procurement Timeline.txt" do
      expect(page).to have_content("Procurement Timeline File Description")
    end
  end
end
