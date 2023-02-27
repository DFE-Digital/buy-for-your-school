require "rails_helper"

describe "Outlook emails integration" do
  def run_sync_inbox_emails! = Support::Messages::Outlook::SynchroniseMailFolder.call(Support::Messages::Outlook::MailFolder.new(folder: :inbox, ms_graph_client:))
  def run_sync_sent_items_emails! = Support::Messages::Outlook::SynchroniseMailFolder.call(Support::Messages::Outlook::MailFolder.new(folder: :sent_items, ms_graph_client:))

  let(:ms_graph_client) { double("MicrosoftGraph.client") }
  let(:inbox_messages) { [] }
  let(:sent_items_messages) { [] }
  let(:file_attachments) { {} }

  before do
    allow(ms_graph_client).to receive(:list_messages_in_folder).with(SHARED_MAILBOX_USER_ID, "Inbox", anything).and_return(inbox_messages)
    allow(ms_graph_client).to receive(:list_messages_in_folder).with(SHARED_MAILBOX_USER_ID, "SentItems", anything).and_return(sent_items_messages)
    allow(ms_graph_client).to receive(:get_file_attachments).and_return([]) if file_attachments.empty?
    file_attachments.each do |message_id, attachments|
      allow(ms_graph_client).to receive(:get_file_attachments).with(SHARED_MAILBOX_USER_ID, message_id).and_return(attachments)
    end
  end

  def stub_message(subject: "Important Email", id: "AAMkAGmnprAAA=")
    message_payload = {
      "body" => { "content" => "c", "contentType" => "cT" },
      "bodyPreview" => "<p>Hello, World</p>",
      "conversationId" => "CONVID123",
      "from" => { "emailAddress" => { "address" => "d", "name" => "e" } },
      "hasAttachments" => true,
      "id" => id,
      "internetMessageId" => "<imid_AAMkAGmnprAAA@mail.gmail.com>",
      "importance" => "high",
      "isDraft" => false,
      "isRead" => true,
      "receivedDateTime" => "2022-12-25T10:30:56Z",
      "sentDateTime" => "2021-11-25T10:28:56Z",
      "subject" => subject,
      "toRecipients" => [
        { "emailAddress" => { "address" => "x", "name" => "y" } },
        { "emailAddress" => { "address" => "a", "name" => "b" } },
      ],
      "singleValueExtendedProperties" => [
        { "id" => "x", "value" => "y" },
        { "id" => "a", "value" => "b" },
      ],
      "uniqueBody" => { "content" => "c", "contentType" => "cT" },
    }
    MicrosoftGraph::Transformer::Message.transform(message_payload, into: MicrosoftGraph::Resource::Message)
  end

  def stub_attachment(id:)
    double("messageAttachment", id:, content_bytes: "1234", content_type: "plain/text", name: "test.txt", is_inline: false, content_id: "CID1")
  end

  describe "email persistance" do
    context "when message is in the inbox" do
      let(:inbox_messages) { [stub_message(subject: "Test Message 1")] }

      it "is saved as a Support::Email in the inbox folder" do
        expect { run_sync_inbox_emails! }.to change(Support::Email, :count).from(0).to(1)
        expect(Support::Email.first.subject).to eq("Test Message 1")
        expect(Support::Email.first.folder).to eq("inbox")
      end

      it "sets action required to true on the case" do
        expect { run_sync_inbox_emails! }.to change{ Support::Email.first&.case&.action_required }.from(nil).to(true)
      end
    end

    context "when message is in the sent items" do
      let(:sent_items_messages) { [stub_message(subject: "Test Message 1")] }

      it "is saved as a Support::Email in the inbox folder" do
        expect { run_sync_sent_items_emails! }.to change(Support::Email, :count).from(0).to(1)
        expect(Support::Email.first.subject).to eq("Test Message 1")
        expect(Support::Email.first.folder).to eq("sent_items")
      end
    end
  end

  describe "case management" do
    context "when message is in the inbox" do
      let(:inbox_messages) { [stub_message(subject: "Case 001234 - Help me Obi Wan")] }

      context "when message cannot be assigned to an existing case" do
        it "creates a new case and is assigned to that case" do
          expect { run_sync_inbox_emails! }.to change(Support::Case, :count).from(0).to(1)
          expect(Support::Case.first.emails.first.subject).to eq("Case 001234 - Help me Obi Wan")
        end

        it "logs in the case history that this case was created by incoming email"
      end

      context "when message can be assigned to an existing case" do
        let!(:existing_case) { create(:support_case, ref: "001234") }

        it "is assigned to the matching case" do
          expect { run_sync_inbox_emails! }.not_to change(Support::Case, :count).from(1)
          expect(existing_case.emails.first.subject).to eq("Case 001234 - Help me Obi Wan")
        end

        context "when the existing case is closed" do
          let!(:existing_case) { create(:support_case, :closed, ref: "001234") }

          it "creates a new case and is assigned to that case" do
            expect { run_sync_inbox_emails! }.to change(Support::Case, :count).from(1).to(2)
            expect(existing_case.emails.count).to eq(0)
            expect(Support::Case.last.emails.first.subject).to eq("Case 001234 - Help me Obi Wan")
          end

          it "logs in the case history that this case was created by incoming email"
        end

        context "when the existing case is resolved" do
          let!(:existing_case) { create(:support_case, :resolved, ref: "001234") }

          it "re-opens the existing case and is assigned to that case" do
            expect { run_sync_inbox_emails! }.not_to change(Support::Case, :count).from(1)
            existing_case.reload
            expect(existing_case.emails.first.subject).to eq("Case 001234 - Help me Obi Wan")
            expect(existing_case.state).to eq("opened")
          end
        end
      end
    end

    context "when message is in sent items" do
      let(:sent_items_messages) { [stub_message(subject: "Case 001234 - Help me Obi Wan")] }

      context "when message cannot be assigned to an existing case" do
        it "creates a new case and is assigned to that case" do
          expect { run_sync_sent_items_emails! }.to change(Support::Case, :count).from(0).to(1)
          expect(Support::Case.first.emails.first.subject).to eq("Case 001234 - Help me Obi Wan")
        end

        it "logs in the case history that this case was created by incoming email"
      end

      context "when message can be assigned to an existing case" do
        let!(:existing_case) { create(:support_case, ref: "001234") }

        it "is assigned to the matching case" do
          run_sync_sent_items_emails!
          expect(existing_case.emails.first.subject).to eq("Case 001234 - Help me Obi Wan")
        end
      end
    end
  end

  describe "email attachments" do
    let(:file_attachments) { { "EMAIL_1" => [stub_attachment(id: "AtA"), stub_attachment(id: "AtB")] } }
    let(:inbox_messages) { [stub_message(id: "EMAIL_1")] }

    it "attaches each email attachment of the message to the persisted email" do
      expect { run_sync_inbox_emails! }.to change(Support::EmailAttachment, :count).from(0).to(2)
      expect(Support::Email.first.attachments.pluck(:outlook_id)).to match_array(%w[AtA AtB])
    end
  end
end
