require "rails_helper"

RSpec.describe "Agent can upload evaluation documents", type: :feature do
  include_context "with an agent"

  let(:support_case) { create(:support_case) }
  let(:file_1) { fixture_file_upload(Rails.root.join("spec/fixtures/support/text-file.txt"), "text/plain") }
  let(:file_2) { fixture_file_upload(Rails.root.join("spec/fixtures/support/another-text-file.txt"), "text/plain") }

  specify "Upload documents" do
    visit edit_support_case_document_uploads_path(case_id: support_case)

    expect(page).to have_text("Upload documents")
    expect(page).to have_text("Upload a file")
    expect(page).to have_text("Have you uploaded all documents?")

    click_button "Continue"

    expect(page).to have_text("There is a problem")
    expect(page).to have_text("Select files to upload")
    expect(page).to have_text("Please confirm that you uploaded all documents")
  end

  context "when files are uploaded" do
    let(:document_uploader) { support_case.document_uploader(files: [file_1, file_2]) }
    let(:is_upload_documents) { true }

    it "attaches the files to the case" do
      expect { document_uploader.save! }.to change { support_case.upload_documents.count }.from(0).to(2)
      expect(support_case.upload_documents.pluck(:file_name)).to contain_exactly("text-file.txt", "another-text-file.txt")
      expect(support_case.upload_documents.map { |a| a.file.attached? }.all?).to eq(true)
    end
  end

  context "when no files are uploaded" do
    let(:document_uploader) { support_case.document_uploader }

    it "fails validation" do
      expect(document_uploader).not_to be_valid
      expect(document_uploader.errors.messages[:files]).to eq ["Select files to upload"]
    end
  end

  context "when uploaded files contain viruses" do
    before do
      allow(Support::VirusScanner).to receive(:uploaded_file_safe?).with(file_1).and_return(true)
      allow(Support::VirusScanner).to receive(:uploaded_file_safe?).with(file_2).and_return(false)
    end

    let(:document_uploader) { support_case.document_uploader(files: [file_1, file_2]) }

    it "fails validation" do
      expect(document_uploader).not_to be_valid
      expect(document_uploader.errors.messages[:files]).to eq ["One or more selected files contained a virus and have been rejected"]
    end
  end
end
