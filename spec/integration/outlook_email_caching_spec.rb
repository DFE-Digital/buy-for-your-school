require "rails_helper"

describe "Outlook emails integration" do
  describe "rolling email sync" do
    def run_sync_inbox_emails! = Email.cache_messages_in_folder("Inbox")
    def run_sync_sent_items_emails! = Email.cache_messages_in_folder("SentItems")

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
      MicrosoftGraph.client = ms_graph_client
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
          expect { run_sync_inbox_emails! }.to change { Support::Email.first&.case&.action_required }.from(nil).to(true)
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

          it "logs in the case history that this case was created by incoming email" do
            expect { run_sync_inbox_emails! }.to change(Support::Interaction, :count).by(1)
            expect(Support::Case.first.interactions.create_case.last.body).to eq("Case created due to receiving email that could not be attached to a currently open case")
          end
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

            it "logs in the case history that this case was created by incoming email" do
              expect { run_sync_inbox_emails! }.to change(Support::Interaction, :count).by(1)
              expect(Support::Case.last.interactions.create_case.last.body).to eq("Case created due to receiving email that could not be attached to a currently open case")
            end
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

    describe "framework evaluations" do
      context "when message is in the inbox" do
        let(:inbox_messages) { [stub_message(subject: "[FE1234] - Help me Obi Wan")] }

        context "when message can be assigned to an existing case" do
          let!(:existing_evaluation) { create(:frameworks_evaluation, reference: "FE1234") }

          it "assigns it to the existing evaluation" do
            expect { run_sync_inbox_emails! }.to change { existing_evaluation.reload.emails.count }.from(0).to(1)
            expect(existing_evaluation.emails.first.subject).to eq("[FE1234] - Help me Obi Wan")
          end

          it "sets the evaluation to action required" do
            expect { run_sync_inbox_emails! }.to change { existing_evaluation.reload.action_required }.from(false).to(true)
          end
        end
      end

      context "when message is in sent items" do
        let(:sent_items_messages) { [stub_message(subject: "[FE1234] - Help me Obi Wan")] }

        context "when message can be assigned to an existing case" do
          let!(:existing_evaluation) { create(:frameworks_evaluation, reference: "FE1234") }

          it "assigns it to the existing evaluation" do
            expect { run_sync_sent_items_emails! }.to change { existing_evaluation.reload.emails.count }.from(0).to(1)
            expect(existing_evaluation.emails.first.subject).to eq("[FE1234] - Help me Obi Wan")
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

      it "can be downloaded by the user", type: :request do
        run_sync_inbox_emails!
        agent_is_signed_in

        support_email_attachment = Support::Email.first.attachments.first
        get support_document_download_path(support_email_attachment, type: "Support::EmailAttachment")
        expect(response.body).to eq(support_email_attachment.file.download)

        email_attachment = Email.first.attachments.first
        get support_document_download_path(email_attachment, type: "EmailAttachment")
        expect(response.body).to eq(email_attachment.file.download)
      end
    end
  end

  describe "resyncing of outlook ids for when emails get moved between folders" do
    subject(:resync_email_ids) { Email.resync_outlook_ids_of_moved_messages }

    before do
      recently_updated_messages_results = [
        { "id" => "OID1", "internetMessageId" => "imid1", "subject" => "Email 1", "sentDateTime" => "2022-01-01T10:00:00Z", "conversationId" => "CID1", "singleValueExtendedProperties" => [{ "id" => "String 0x1042", "value" => "in-reply-to-id-3" }] },
        { "id" => "OID2", "internetMessageId" => "imid2", "subject" => "Email 2", "sentDateTime" => "2022-01-01T10:10:00Z" },
        { "id" => "OID3", "internetMessageId" => "imid3", "subject" => "Email 2", "sentDateTime" => "2022-01-01T10:12:00Z", "conversationId" => "CID3", "singleValueExtendedProperties" => [{ "id" => "String 0x1042", "value" => "in-reply-to-id-5" }] },
      ]

      allow(MicrosoftGraph).to receive(:client).and_return(double(list_messages: recently_updated_messages_results))
      allow(Email).to receive(:default_mailbox).and_return(double(user_id: 1))
    end

    context "when an email exists with a matching internetMessageId" do
      let!(:existing_email) { create(:support_email, outlook_internet_message_id: "imid1", outlook_id: "OLD-OID1", outlook_conversation_id: nil) }

      context "and the outlook id for that email differs from the message resource" do
        it "updates the emails outlook id from the message resource" do
          resync_email_ids
          expect(existing_email.reload.outlook_id).to eq("OID1")
        end
      end

      context "and the outlook id is the same for the email as in the message resource" do
        before { existing_email.update(outlook_id: "OID1") }

        it "does not update the email record" do
          expect { resync_email_ids }.not_to(change { existing_email.reload.outlook_id })
        end
      end

      context "and the outlook conversation id is not set on the email" do
        it "sets the outlook conversation id on the email using the values from the message" do
          resync_email_ids
          expect(existing_email.reload.outlook_conversation_id).to eq("CID1")
        end
      end

      context "and the in_reply_to_id is not set on the email" do
        it "sets the in_reply_to_id on the email using the values from the message" do
          resync_email_ids
          expect(existing_email.reload.in_reply_to_id).to eq("in-reply-to-id-3")
        end
      end
    end

    context "when an email exists with both matching subject and sent times" do
      let!(:existing_email) { create(:support_email, outlook_id: "OLD-OID1", subject: "Email 2", sent_at: "2022-01-01T10:12:00Z") }

      it "updates the emails outlook id from the message resource" do
        resync_email_ids
        expect(existing_email.reload.outlook_id).to eq("OID3")
      end

      it "updates the emails internet message id from the message resource" do
        resync_email_ids
        expect(existing_email.reload.outlook_internet_message_id).to eq("imid3")
      end

      context "and the outlook conversation id is not set on the email" do
        it "sets the outlook conversation id on the email using the values from the message" do
          resync_email_ids
          expect(existing_email.reload.outlook_conversation_id).to eq("CID3")
        end
      end

      context "and the in_reply_to_id is not set on the email" do
        it "sets the in_reply_to_id on the email using the values from the message" do
          resync_email_ids
          expect(existing_email.reload.in_reply_to_id).to eq("in-reply-to-id-5")
        end
      end
    end
  end
end
