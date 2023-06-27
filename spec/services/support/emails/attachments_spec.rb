require "rails_helper"

describe Support::Emails::Attachments do
  describe "self.get_class" do
    it "returns the class for given type" do
      expect(described_class.get_class("template_attachment")).to eq(Support::EmailTemplateAttachment)
    end
  end

  describe "self.get_type" do
    it "returns the type for given class" do
      expect(described_class.get_type(Support::EmailTemplateAttachment)).to eq("template_attachment")
    end
  end

  describe "self.resolve_blob_attachments" do
    let(:template_attachment) { create(:support_email_template_attachment) }
    let(:blob_attachments) do
      [
        {
          "type" => "template_attachment",
          "file_id" => template_attachment.id,
        },
      ]
    end

    it "returns the matching records based on type and ID" do
      expect(described_class.resolve_blob_attachments(blob_attachments)).to match_array([template_attachment])
    end
  end
end
