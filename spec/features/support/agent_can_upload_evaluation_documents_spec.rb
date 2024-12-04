require "rails_helper"

describe "Agent can upload evaluation documents", :js do
  include_context "with an agent"

  let(:support_case) { create(:support_case) }
  let(:file_1) { Rails.root.join("spec/fixtures/support/text-file.txt") }
  let(:file_2) { Rails.root.join("spec/fixtures/support/another-text-file.txt") }

  specify "Upload documents" do
    visit edit_support_case_document_uploads_path(case_id: support_case)

    expect(page).to have_text("Upload documents")
    expect(page).to have_text("Upload a file")
    expect(page).to have_text("Have you uploaded all documents?")

    click_button "Continue"

    expect(page).to have_text("There is a problem")
    expect(page).to have_text("Select files to upload")
    expect(page).to have_text("Please confirm that you uploaded all documents")

    attach_file("support_case_document_uploader_files", file_1)
    attach_file("support_case_document_uploader_files", file_2)

    click_button "Continue"

    expect(page).to have_text("There is a problem")
    expect(page).to have_text("Please confirm that you uploaded all documents")

    attach_file("support_case_document_uploader_files", file_1)
    attach_file("support_case_document_uploader_files", file_2)

    choose("No")

    click_button "Continue"

    expect(find("#complete-evaluation-3-status")).to have_text("In progress")

    click_link "complete-evaluation-3-status"

    choose("Yes, I have uploaded all documents")

    click_button "Continue"

    expect(find("#complete-evaluation-3-status")).to have_text("Complete")
  end
end
