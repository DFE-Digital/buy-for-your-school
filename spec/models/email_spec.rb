require "rails_helper"

describe Email do
  subject(:email) { described_class.create(attachments:) }

  let(:attachments) do
    [
      create(:email_attachment, file: Rack::Test::UploadedFile.new(Rails.root.join("spec/fixtures/files/text-file.txt"), "text/plain")),
      create(:email_attachment, file: Rack::Test::UploadedFile.new(Rails.root.join("spec/fixtures/files/another-text-file.txt"), "text/plain")),
    ]
  end

  describe "#total_attachment_size" do
    it "returns the total size of all attachments" do
      expect(email.total_attachment_size).to eq(38)
    end
  end
end
