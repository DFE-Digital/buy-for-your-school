require "rails_helper"

describe Support::Email do
  describe "#import_from_message" do
    let(:has_attachments) { false }
    let(:email) { build(:support_email) }

    let(:message) do
      double(
        id: "ID_123",
        conversation_id: "CID_456",
        from: double(email_address: double(address: "sender@email.com", name: "Sender")),
        subject: "Synced email #1",
        is_read: true,
        is_draft: false,
        body_preview: "body preview",
        body: double(content: "body", content_type: "html"),
        received_date_time: Time.zone.now,
        sent_date_time: Time.zone.now - 1.hour,
        has_attachments: has_attachments,
        to_recipients: [
          double(email_address: double(address: "receipient1@email.com", name: "Recipient 1")),
          double(email_address: double(address: "receipient2@email.com", name: "Recipient 2")),
        ],
      )
    end

    context "when a folder is given" do
      it "sets the folder to the given value" do
        email.import_from_message(message, folder: :sent_items)
        expect(email.folder).to eq("sent_items")
      end
    end

    context "when a folder is not given" do
      it "sets the folder to :inbox" do
        email.import_from_message(message)
        expect(email.folder).to eq("inbox")
      end
    end

    context "when message has no attachments" do
      let(:has_attachments) { false }

      it "calls IncomingEmails::EmailAttachments.download with the email" do
        allow(Support::IncomingEmails::EmailAttachments).to receive(:download)

        email.import_from_message(message)

        expect(Support::IncomingEmails::EmailAttachments).not_to have_received(:download)
      end
    end

    context "when message has attachments" do
      let(:has_attachments) { true }

      it "calls IncomingEmails::EmailAttachments.download with the email" do
        allow(Support::IncomingEmails::EmailAttachments).to receive(:download)

        email.import_from_message(message)

        expect(Support::IncomingEmails::EmailAttachments).to have_received(:download).with(email: email)
      end
    end

    it "sets all necessary fields on the Support::Email record" do
      email.import_from_message(message)
      email.reload
      expect(email.subject).to eq("Synced email #1")
      expect(email.outlook_conversation_id).to eq("CID_456")
      expect(email.outlook_id).to eq("ID_123")
      expect(email.sender).to eq({ "address" => "sender@email.com", "name" => "Sender" })
      expect(email.is_read).to eq(true)
      expect(email.is_draft).to eq(false)
      expect(email.has_attachments).to eq(false)
      expect(email.body_preview).to eq("body preview")
      expect(email.body).to eq("body")
      expect(email.received_at).to be_within(1.second).of(message.received_date_time)
      expect(email.sent_at).to be_within(1.second).of(message.sent_date_time)
      expect(email.recipients).to eq([
        { "address" => "receipient1@email.com", "name" => "Recipient 1" },
        { "address" => "receipient2@email.com", "name" => "Recipient 2" },
      ])
    end
  end

  describe "#automatically_assign_case" do
    let(:email) { build(:support_email) }

    it "detects and assigns a case to the email" do
      allow(Support::IncomingEmails::CaseAssignment).to receive(:detect_and_assign_case)

      email.automatically_assign_case

      expect(Support::IncomingEmails::CaseAssignment).to have_received(:detect_and_assign_case).with(email).once
    end

    context "when the email has already been assigned a case" do
      before { email.case = create(:support_case) }

      it "does not try to change it again" do
        allow(Support::IncomingEmails::CaseAssignment).to receive(:detect_and_assign_case)

        email.automatically_assign_case

        expect(Support::IncomingEmails::CaseAssignment).not_to have_received(:detect_and_assign_case).with(email)
      end
    end
  end

  describe "#create_interaction" do
    let(:folder) { :inbox }
    let(:email) { create(:support_email, case: support_case, body: "Body Here", folder: folder) }

    before { allow(Support::CreateInteraction).to receive(:new) }

    context "when case is not set" do
      let(:support_case) { nil }

      it "does create an interaction" do
        email.create_interaction
        expect(Support::CreateInteraction).not_to have_received(:new)
      end
    end

    context "when case is set" do
      let(:create_interaction) { double(call: true) }
      let(:support_case) { create(:support_case) }

      before { allow(Support::CreateInteraction).to receive(:new).and_return(create_interaction) }

      context "when folder is inbox" do
        let(:folder) { :inbox }

        it "creates an email_from_school interaction" do
          email.create_interaction

          expect(Support::CreateInteraction).to have_received(:new).with(
            support_case.id,
            "email_from_school",
            nil,
            {
              body: email.body,
              additional_data: { email_id: email.id },
            },
          )
          expect(create_interaction).to have_received(:call).once
        end
      end

      context "when folder is sent_items" do
        let(:folder) { :sent_items }

        it "creates an email_to_school interaction" do
          email.create_interaction

          expect(Support::CreateInteraction).to have_received(:new).with(
            support_case.id,
            "email_to_school",
            nil,
            {
              body: email.body,
              additional_data: { email_id: email.id },
            },
          )
          expect(create_interaction).to have_received(:call).once
        end
      end
    end
  end

  describe ".import_from_mailbox" do
    let(:email) { build(:support_email, case: nil) }

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

    before { allow(described_class).to receive(:find_or_initialize_by).and_return(email) }

    it "imports the email" do
      allow(email).to receive(:import_from_message)

      described_class.import_from_mailbox(message, folder: :x)

      expect(email).to have_received(:import_from_message).with(message, folder: :x).once
    end

    it "assigns the case" do
      allow(email).to receive(:automatically_assign_case)

      described_class.import_from_mailbox(message)

      expect(email).to have_received(:automatically_assign_case).once
    end

    it "creates an interaction" do
      allow(email).to receive(:create_interaction)

      described_class.import_from_mailbox(message)

      expect(email).to have_received(:create_interaction).once
    end
  end
end
