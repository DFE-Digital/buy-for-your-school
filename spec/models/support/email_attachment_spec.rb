require "rails_helper"

RSpec.describe Support::EmailAttachment, type: :model do
  subject(:attachment) { build(:support_email_attachment) }

  it "updates the file_name attribute to match the file name" do
    attachment.save!

    expect(attachment.file_name).to eq("attachment.txt")
  end

  it "updates the file_type attribute to match the file type" do
    attachment.save!

    expect(attachment.file_type).to eq("text/plain")
  end

  it "updates the file_size attribute to match the file size" do
    attachment.save!

    expect(attachment.file_size).to eq(35)
  end

  describe ".unique_files" do
    let!(:attachment_1) { create(:support_email_attachment, file: fixture_file_upload(Rails.root.join("spec/fixtures/support/text-file.txt"), "text/plain"), created_at: 1.week.ago) }
    let!(:attachment_2) { create(:support_email_attachment, file: fixture_file_upload(Rails.root.join("spec/fixtures/support/text-file.txt"), "text/plain"), created_at: 1.day.ago) }
    let!(:attachment_3) { create(:support_email_attachment, file: fixture_file_upload(Rails.root.join("spec/fixtures/support/another-text-file.txt"), "text/plain")) }

    it "removes repeating duplicate files" do
      results = described_class.unique_files.to_a

      expect(results).not_to include(attachment_1) # older duplicate
      expect(results).to include(attachment_2)
      expect(results).to include(attachment_3)
    end
  end

  describe ".all_instances" do
    let!(:attachment_1) { create(:support_email_attachment, file: fixture_file_upload(Rails.root.join("spec/fixtures/support/text-file.txt"), "text/plain"), created_at: 1.week.ago) }
    let!(:attachment_2) { create(:support_email_attachment, file: fixture_file_upload(Rails.root.join("spec/fixtures/support/text-file.txt"), "text/plain"), created_at: 1.day.ago) }
    let!(:attachment_3) { create(:support_email_attachment, file: fixture_file_upload(Rails.root.join("spec/fixtures/support/another-text-file.txt"), "text/plain")) }

    it "provides repeating duplicate files, so they can be hidden" do
      results = described_class.all_instances(attachment_1).to_a
      expect(results).to include(attachment_1)
      expect(results).to include(attachment_2)
      results = described_class.all_instances(attachment_2).to_a
      expect(results).to include(attachment_1)
      expect(results).to include(attachment_2)
      results = described_class.all_instances(attachment_3).to_a
      expect(results).to include(attachment_3)
    end
  end
end
