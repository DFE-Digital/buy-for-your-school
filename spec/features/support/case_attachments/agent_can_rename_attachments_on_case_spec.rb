require "rails_helper"

describe "Agent can rename attachments on a case" do
  include_context "with an agent"

  let(:support_case) { create(:support_case) }
  let(:file) { fixture_file_upload(Rails.root.join("spec/fixtures/support/text-file.txt"), "text/plain") }

  before do
    create(:support_email_attachment, file:, email: create(:support_email, :inbox, case: support_case))
  end

  it "adds a custom name and description to the attachment", js: true do
    visit support_case_path(support_case)

    click_link "Attachments"
    within "#case-attachments tr", text: "text-file.txt" do
      click_link "Edit"
    end

    fill_in "File name", with: "Procurement Timeline"
    fill_in "Description", with: "Procurement Timeline File Description"
    click_button "Save"

    within "#case-attachments tr", text: "Procurement Timeline.txt" do
      expect(page).to have_content("Procurement Timeline File Description")
    end
  end
end
