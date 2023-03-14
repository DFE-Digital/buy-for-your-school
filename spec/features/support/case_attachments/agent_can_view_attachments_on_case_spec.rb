require "rails_helper"

describe "Agent can view attachments on a case" do
  include_context "with an agent"

  before { click_button "Agent Login" }

  context "when there are attachments on the case" do
    let(:support_case)  { create(:support_case) }
    let!(:attachment_1) { create(:support_case_attachment, case: support_case, custom_name: "Classroom.pdf", description: "Classroom Layout Design") }
    let!(:attachment_2) { create(:support_case_attachment, case: support_case, custom_name: "Meeting Recording.wav", description: "Meeting recording from dictaphone") }

    it "displays them within the Files tab", js: true do
      visit support_case_path(support_case)

      within "#case-files tr", text: "Classroom.pdf" do
        expect(page).to have_content("Classroom Layout Design")
        expect(page).to have_link("Classroom.pdf", href: support_document_download_path(attachment_1, type: "Support::CaseAttachment"))
      end

      within "#case-files tr", text: "Meeting Recording.wav" do
        expect(page).to have_content("Meeting recording from dictaphone")
        expect(page).to have_link("Meeting Recording.wav", href: support_document_download_path(attachment_2, type: "Support::CaseAttachment"))
      end
    end
  end
end
