require "rails_helper"

describe Support::Messages::Outlook::Reply::UploadedFileAttachment do
  subject(:file_attachment) { described_class.new(file:, name: "example_schools_data.csv") }

  let(:file) { File.open(Rails.root.join("spec/fixtures/gias/example_schools_data.csv")) }

  describe "#content_bytes" do
    it "returns the file contents base64 encoded" do
      actual = file_attachment.content_bytes
      file.rewind
      expected = Base64.encode64(file.read)
      expect(actual).to eq(expected)
    end
  end

  describe "#content_type" do
    it "returns the mimetype of the file" do
      expect(file_attachment.content_type).to eq("text/csv")
    end
  end
end
