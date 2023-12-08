require "rails_helper"

describe EmailAttachment::Draftable do
  subject(:draftable) { EmailAttachment }

  let(:email) { create(:support_email, :inbox) }
  let(:file_1) { fixture_file_upload(Rails.root.join("spec/fixtures/support/text-file.txt"), "text/plain") }
  let(:file_2) { fixture_file_upload(Rails.root.join("spec/fixtures/support/another-text-file.txt"), "text/plain") }

  before do
    create(:support_email_attachment, file: file_1, outlook_id: nil, email:)
    create(:support_email_attachment, file: file_2, outlook_id: nil, email:)
  end

  describe ".delete_draft_attachments_for_email" do
    it "deletes all draft attachments on the given email" do
      expect { draftable.delete_draft_attachments_for_email(email) }.to change { email.attachments.draft.count }.from(2).to(0)
    end
  end
end
