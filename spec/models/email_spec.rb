require "rails_helper"

describe Email do
  subject(:email) { described_class.create(attachments:) }

  let(:attachments) do
    [
      create(:email_attachment, file: Rack::Test::UploadedFile.new(Rails.root.join("spec/fixtures/specification_templates/food_catering.liquid"), "text/html")),
      create(:email_attachment, file: Rack::Test::UploadedFile.new(Rails.root.join("spec/fixtures/contentful/001-categories/category-with-dynamic-liquid-template.json"), "application/json")),
    ]
  end

  describe "#total_attachment_size" do
    it "returns the total size of all attachments" do
      expect(email.total_attachment_size).to eq(3680)
    end
  end
end
