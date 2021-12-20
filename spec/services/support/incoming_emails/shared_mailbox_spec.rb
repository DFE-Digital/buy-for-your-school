require "rails_helper"

describe Support::IncomingEmails::SharedMailbox do
  describe "#synchronize" do
    subject(:mailbox) { described_class.new(graph_client: graph_client) }

    let(:graph_client) { double }
    let(:email) do
      double(
        id: "ID_123",
        conversation_id: "CID_456",
        subject: "Synced email #1",
        is_read: true,
        is_draft: false,
        has_attachments: false,
        body_preview: "body preview",
        body: double(content: "body", content_type: "html"),
        received_date_time: Time.zone.now,
        sent_date_time: Time.zone.now - 1.hour,
        to_recipients: [
          double(email_address: double(address: "receipient1@email.com", name: "Recipient 1")),
          double(email_address: double(address: "receipient2@email.com", name: "Recipient 2")),
        ],
      )
    end

    before do
      stub_const("SHARED_MAILBOX_USER_ID", "1")
      stub_const("SHARED_MAILBOX_FOLDER_ID", "2")

      allow(graph_client).to receive(:list_messages_in_folder)
        .with(SHARED_MAILBOX_USER_ID, SHARED_MAILBOX_FOLDER_ID, query: anything)
        .and_return([email])
    end

    context "when mail client has new emails" do
      it "converts each email into an Support::Email record" do
        expect { mailbox.synchronize }
          .to  change { Support::Email.count }.from(0).to(1)
          .and change { Support::Email.where(outlook_conversation_id: "CID_456", outlook_id: "ID_123").count }
          .from(0).to(1)
      end

      it "sets all necessary fields on the Support::Email record" do
        mailbox.synchronize

        support_email = Support::Email.first
        expect(support_email.subject).to eq("Synced email #1")
        expect(support_email.outlook_conversation_id).to eq("CID_456")
        expect(support_email.outlook_id).to eq("ID_123")
        expect(support_email.is_read).to eq(true)
        expect(support_email.is_draft).to eq(false)
        expect(support_email.has_attachments).to eq(false)
        expect(support_email.body_preview).to eq("body preview")
        expect(support_email.body).to eq("body")
        expect(support_email.received_at).to be_within(1.second).of(email.received_date_time)
        expect(support_email.sent_at).to be_within(1.second).of(email.sent_date_time)

        expect(support_email.recipients).to eq([
          { "address" => "receipient1@email.com", "name" => "Recipient 1" },
          { "address" => "receipient2@email.com", "name" => "Recipient 2" },
        ])
      end

      context "when the email has already been recorded locally" do
        before { create(:support_email, outlook_conversation_id: "CID_456", outlook_id: "ID_123", subject: "Synced email #1") }

        it "keeps the existing record instead of creating a new one" do
          expect { mailbox.synchronize }.not_to change {
            Support::Email.where(
              outlook_conversation_id: "CID_456",
              outlook_id: "ID_123",
              subject: "Synced email #1",
            ).count
          }
        end
      end
    end
  end
end
