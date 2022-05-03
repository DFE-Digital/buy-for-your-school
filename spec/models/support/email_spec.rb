require "rails_helper"

describe Support::Email do
  before { allow(Support::IncomingEmails::EmailAttachments).to receive(:download).and_return(nil) }

  describe "#has_unattachable_files_attached?" do
    let(:email) { create(:support_email) }

    context "when there are more attachments than are acceptable" do
      before do
        create(:support_email_attachment, email: email).tap { |a| a.update(file_type: CASE_ATTACHMENT_FILE_TYPE_ALLOW_LIST.first) }
        create(:support_email_attachment, email: email).tap { |a| a.update(file_type: "unacceptable") }
      end

      it "returns true" do
        expect(email.has_unattachable_files_attached?).to eq(true)
      end
    end

    context "when all attachments are acceptable" do
      before do
        create(:support_email_attachment, email: email).tap { |a| a.update(file_type: CASE_ATTACHMENT_FILE_TYPE_ALLOW_LIST.first) }
        create(:support_email_attachment, email: email).tap { |a| a.update(file_type: CASE_ATTACHMENT_FILE_TYPE_ALLOW_LIST.first) }
      end

      it "returns false" do
        expect(email.has_unattachable_files_attached?).to eq(false)
      end
    end
  end
end
