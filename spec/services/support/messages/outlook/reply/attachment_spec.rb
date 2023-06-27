require "rails_helper"

describe Support::Messages::Outlook::Reply::Attachment do
  describe "self.create" do
    describe "returns the right subclass object based on attachment type" do
      context "when the attachment in an uploaded file" do
        let(:hash) do
          {
            tempfile: double("tempfile"),
            filename: "uploaded_file",
          }
        end
        let(:uploaded_file) { ActionDispatch::Http::UploadedFile.new(hash) }

        it "returns an UploadedFileAttachment object" do
          expect(described_class.create(uploaded_file)).to be_a(Support::Messages::Outlook::Reply::UploadedFileAttachment)
        end
      end

      context "when the attachment is a blob" do
        let(:blob) { ActiveStorage::Blob.new }

        it "returns a BlobAttachment object" do
          expect(described_class.create(blob)).to be_a(Support::Messages::Outlook::Reply::BlobAttachment)
        end
      end
    end
  end
end
