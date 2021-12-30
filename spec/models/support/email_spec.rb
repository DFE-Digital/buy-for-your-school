require "rails_helper"

describe Support::Email do
  describe ".import_from_mailbox" do
    let(:message) do
      double(
        id: "ID_123",
        conversation_id: "CID_456",
        from: double(email_address: double(address: "sender@email.com", name: "Sender")),
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

    it "converts each email into an Support::Email record" do
      expect { described_class.import_from_mailbox(message) }
        .to  change(described_class, :count).from(0).to(1)
        .and change { described_class.where(outlook_conversation_id: "CID_456", outlook_id: "ID_123").count }
        .from(0).to(1)
    end

    context "when a folder is given" do
      it "sets the folder to the given value" do
        described_class.import_from_mailbox(message, folder: :sent_items)

        support_email = described_class.first
        expect(support_email.folder).to eq("sent_items")
      end
    end

    context "when a folder is not given" do
      it "sets the folder to :inbox" do
        described_class.import_from_mailbox(message)

        support_email = described_class.first
        expect(support_email.folder).to eq("inbox")
      end
    end

    it "sets all necessary fields on the Support::Email record" do
      described_class.import_from_mailbox(message)

      support_email = described_class.first
      expect(support_email.subject).to eq("Synced email #1")
      expect(support_email.outlook_conversation_id).to eq("CID_456")
      expect(support_email.outlook_id).to eq("ID_123")
      expect(support_email.sender).to eq({ "address" => "sender@email.com", "name" => "Sender" })
      expect(support_email.is_read).to eq(true)
      expect(support_email.is_draft).to eq(false)
      expect(support_email.has_attachments).to eq(false)
      expect(support_email.body_preview).to eq("body preview")
      expect(support_email.body).to eq("body")
      expect(support_email.received_at).to be_within(1.second).of(message.received_date_time)
      expect(support_email.sent_at).to be_within(1.second).of(message.sent_date_time)
      expect(support_email.recipients).to eq([
        { "address" => "receipient1@email.com", "name" => "Recipient 1" },
        { "address" => "receipient2@email.com", "name" => "Recipient 2" },
      ])
    end

    context "when the message has already been converted" do
      before { described_class.import_from_mailbox(message) }

      it "keeps the existing record instead of creating a new one" do
        expect { described_class.import_from_mailbox(message) }.not_to change {
          described_class.where(
            outlook_conversation_id: "CID_456",
            outlook_id: "ID_123",
            subject: "Synced email #1",
          ).count
        }.from(1)
      end
    end

    describe "assigning a case" do
      it "detects and assigns a case to the email" do
        allow(Support::IncomingEmails::CaseAssignment).to receive(:detect_and_assign_case)

        email = build(:support_email, case: nil)
        allow(described_class).to receive(:find_or_initialize_by).and_return(email)

        described_class.import_from_mailbox(message)

        expect(Support::IncomingEmails::CaseAssignment).to have_received(:detect_and_assign_case).with(email)
      end

      context "when the email has already been assigned a case" do
        it "does not try to change it again" do
          allow(Support::IncomingEmails::CaseAssignment).to receive(:detect_and_assign_case)

          email = build(:support_email)
          allow(described_class).to receive(:find_or_initialize_by).and_return(email)

          described_class.import_from_mailbox(message)

          expect(Support::IncomingEmails::CaseAssignment).not_to have_received(:detect_and_assign_case).with(email)
        end
      end
    end
  end
end
