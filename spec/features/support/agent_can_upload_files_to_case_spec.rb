require "rails_helper"

describe "Agent can upload files to a case" do
  let(:support_case) { create(:support_case) }

  let(:file_1) { fixture_file_upload(Rails.root.join("spec/fixtures/support/text-file.txt"), "text/plain") }
  let(:file_2) { fixture_file_upload(Rails.root.join("spec/fixtures/support/another-text-file.txt"), "text/plain") }

  let(:file_uploader) { support_case.file_uploader(files: [file_1, file_2]) }

  context "when files are uploaded" do
    it "attaches the files to the case" do
      expect { file_uploader.save! }.to change { support_case.case_attachments.count }.from(0).to(2)
      expect(support_case.case_attachments.pluck(:custom_name)).to contain_exactly("text-file.txt", "another-text-file.txt")
      expect(support_case.case_attachments.map { |a| a.file.attached? }.all?).to eq(true)
    end
  end

  context "when no files are uploaded" do
    let(:file_uploader) { support_case.file_uploader }

    it "fails validation" do
      expect(file_uploader).not_to be_valid
      expect(file_uploader.errors.messages[:files]).to eq ["Select files to upload"]
    end
  end

  context "when uploaded files contain viruses" do
    before do
      allow(Support::VirusScanner).to receive(:uploaded_file_safe?).with(file_1).and_return(true)
      allow(Support::VirusScanner).to receive(:uploaded_file_safe?).with(file_2).and_return(false)
    end

    it "fails validation" do
      expect(file_uploader).not_to be_valid
      expect(file_uploader.errors.messages[:files]).to eq ["One or more selected files contained a virus and have been rejected"]
    end
  end
end
