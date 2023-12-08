require "rails_helper"

describe "Attaching files to emails" do
  let(:support_case) { create(:support_case, :initial) }
  let(:existing_inbox_email) { create(:email, folder: :inbox, ticket: support_case) }
  let(:existing_sent_email) { create(:email, folder: :sent_items, ticket: support_case) }
  let(:draft_email) { create(:email, is_draft: true, ticket: support_case) }
  let(:file_1) { fixture_file_upload(Rails.root.join("spec/fixtures/support/text-file.txt"), "text/plain") }
  let(:file_2) { fixture_file_upload(Rails.root.join("spec/fixtures/support/another-text-file.txt"), "text/plain") }
  let(:back_to) { edit_support_case_message_thread_path(case_id: support_case.id, id: draft_email.id) }

  let(:headers) { { "Turbo-Frame" => "1" } }

  before { agent_is_signed_in }

  describe "Attaching existing email attachments to an email" do
    let(:email_attachment_1) { create(:support_email_attachment, file_name: "text-file.txt", file: file_1, email: existing_inbox_email) }
    let(:email_attachment_2) { create(:support_email_attachment, file_name: "another-text-file.txt", file: file_2, email: existing_sent_email) }

    let(:params) do
      {
        blob_attachment_picker: {
          attachments: [
            { file_id: email_attachment_1.id, type: email_attachment_1.class }.to_json,
            { file_id: email_attachment_2.id, type: email_attachment_2.class }.to_json,
          ],
        },
      }
    end

    before do
      post attach_email_attachments_path(message_id: draft_email.id, back_to: Base64.encode64(back_to)), params:, headers:
    end

    it "attaches the new email attachments" do
      expect(draft_email.attachments.draft.count).to eq(2)
      expect(draft_email.attachments.draft.pluck(:file_name)).to match_array(%w[text-file.txt another-text-file.txt])
    end

    it "redirects back" do
      expect(response).to redirect_to(back_to)
    end
  end

  describe "Attaching case files to an email" do
    let(:support_document_1) { create(:support_document, file: file_1) }
    let(:support_document_2) { create(:support_document, file: file_2) }
    let(:case_attachment_1) { create(:support_case_attachment, name: "text-file.txt", attachable: support_document_1, case: support_case) }
    let(:case_attachment_2) { create(:support_case_attachment, name: "another-text-file.txt", attachable: support_document_2, case: support_case) }

    let(:params) do
      {
        blob_attachment_picker: {
          attachments: [
            { file_id: case_attachment_1.id, type: case_attachment_1.class }.to_json,
            { file_id: case_attachment_2.id, type: case_attachment_2.class }.to_json,
          ],
        },
      }
    end

    before do
      post attach_case_files_path(message_id: draft_email.id, back_to: Base64.encode64(back_to)), params:, headers:
    end

    it "attaches case files" do
      expect(draft_email.attachments.draft.count).to eq(2)
      expect(draft_email.attachments.draft.pluck(:file_name)).to match_array(%w[text-file.txt another-text-file.txt])
    end

    it "redirects back" do
      expect(response).to redirect_to(back_to)
    end
  end

  describe "Attaching file uploads to an email" do
    let(:params) do
      {
        file: file_1,
      }
    end

    context "when the file is safe" do
      before do
        allow(Support::VirusScanner).to receive(:uploaded_file_safe?).and_return(true)
        post attachments_messages_path(message_id: draft_email.id), params:
      end

      it "attaches the file to the email" do
        expect(draft_email.attachments.draft.count).to eq(1)
        expect(draft_email.attachments.draft.pluck(:file_name)).to match_array(%w[text-file.txt])
      end

      it "responds with file id and name" do
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)).to include("file_id" => a_kind_of(String), "name" => "text-file.txt")
      end
    end

    context "when the file is not safe" do
      before do
        allow(Support::VirusScanner).to receive(:uploaded_file_safe?).and_return(false)
        post attachments_messages_path(message_id: draft_email.id), params:
      end

      it "does not attach the file to the email" do
        expect(draft_email.attachments.draft.count).to eq(0)
      end

      it "responds with an error" do
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)).to include("file" => ["virus detected"])
      end
    end
  end
end
