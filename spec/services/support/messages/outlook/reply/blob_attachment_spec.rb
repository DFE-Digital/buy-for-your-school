require "rails_helper"

describe Support::Messages::Outlook::Reply::BlobAttachment do
  subject(:blob_attachment) { described_class.new(blob) }

  let(:blob) { create(:support_email_template_attachment).file.blob }

  describe "#name" do
    it "returns the blob name" do
      expect(blob_attachment.name).to eq("attachment.txt")
    end
  end

  describe "#content_bytes" do
    it "returns the file contents base64 encoded" do
      actual = blob_attachment.content_bytes
      expected = blob.open do |tempfile|
        tempfile.rewind
        Base64.encode64(tempfile.read)
      end
      expect(actual).to eq(expected)
    end
  end

  describe "#content_type" do
    it "returns the mimetype of the blob" do
      expect(blob_attachment.content_type).to eq("text/plain")
    end
  end
end
