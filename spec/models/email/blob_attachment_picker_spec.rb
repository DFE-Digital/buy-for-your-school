require "rails_helper"

describe Email::BlobAttachmentPicker do
  subject(:blob_attachment_picker) { described_class.new }

  describe "Validations" do
    it "is not valid without attachments" do
      expect(blob_attachment_picker).not_to be_valid(:attachments)
      expect(blob_attachment_picker.errors.messages[:attachments]).to eq(["Select files to attach"])
    end
  end
end
