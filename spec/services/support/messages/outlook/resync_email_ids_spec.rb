require "rails_helper"

describe Support::Messages::Outlook::ResyncEmailIds do
  subject(:resync_email_ids)    { described_class.new(messages_updated_after:, ms_graph_client:) }

  let(:ms_graph_client)         { double("ms_graph_client") }
  let(:messages_updated_after)  { 10.minutes.ago }

  before do
    recently_updated_messages_results = [
      { "id" => "OID1", "internetMessageId" => "imid1", "subject" => "Email 1", "sentDateTime" => "2022-01-01T10:00:00Z", "conversationId" => "CID1", "singleValueExtendedProperties" => [{ "id" => "String 0x1042", "value" => "in-reply-to-id-3" }] },
      { "id" => "OID2", "internetMessageId" => "imid2", "subject" => "Email 2", "sentDateTime" => "2022-01-01T10:10:00Z" },
      { "id" => "OID3", "internetMessageId" => "imid3", "subject" => "Email 2", "sentDateTime" => "2022-01-01T10:12:00Z", "conversationId" => "CID3", "singleValueExtendedProperties" => [{ "id" => "String 0x1042", "value" => "in-reply-to-id-5" }] },
    ]

    allow(ms_graph_client).to receive(:list_messages).with(SHARED_MAILBOX_USER_ID, query: [
      "$filter=lastModifiedDateTime ge #{messages_updated_after.utc.iso8601}",
      "$select=internetMessageId,subject,sentDateTime,conversationId",
      "$orderby=lastModifiedDateTime asc",
      "$expand=singleValueExtendedProperties($filter=id eq '#{MicrosoftGraph::Resource::SingleValueExtendedProperty::ID_PR_IN_REPLY_TO_ID}')",
    ]).and_return(recently_updated_messages_results)
  end

  context "when an email exists with a matching internetMessageId" do
    let!(:existing_email) { create(:support_email, outlook_internet_message_id: "imid1", outlook_id: "OLD-OID1", outlook_conversation_id: nil) }

    context "and the outlook id for that email differs from the message resource" do
      it "updates the emails outlook id from the message resource" do
        resync_email_ids.call
        expect(existing_email.reload.outlook_id).to eq("OID1")
      end
    end

    context "and the outlook id is the same for the email as in the message resource" do
      before { existing_email.update(outlook_id: "OID1") }

      it "does not update the email record" do
        expect { resync_email_ids.call }.not_to change { existing_email.reload.outlook_id }
      end
    end

    context "and the outlook conversation id is not set on the email" do
      it "sets the outlook conversation id on the email using the values from the message" do
        resync_email_ids.call
        expect(existing_email.reload.outlook_conversation_id).to eq("CID1")
      end
    end

    context "and the in_reply_to_id is not set on the email" do
      it "sets the in_reply_to_id on the email using the values from the message" do
        resync_email_ids.call
        expect(existing_email.reload.in_reply_to_id).to eq("in-reply-to-id-3")
      end
    end
  end

  context "when an email exists with both matching subject and sent times" do
    let!(:existing_email) { create(:support_email, outlook_id: "OLD-OID1", subject: "Email 2", sent_at: "2022-01-01T10:12:00Z") }

    it "updates the emails outlook id from the message resource" do
      resync_email_ids.call
      expect(existing_email.reload.outlook_id).to eq("OID3")
    end

    it "updates the emails internet message id from the message resource" do
      resync_email_ids.call
      expect(existing_email.reload.outlook_internet_message_id).to eq("imid3")
    end

    context "and the outlook conversation id is not set on the email" do
      it "sets the outlook conversation id on the email using the values from the message" do
        resync_email_ids.call
        expect(existing_email.reload.outlook_conversation_id).to eq("CID3")
      end
    end

    context "and the in_reply_to_id is not set on the email" do
      it "sets the in_reply_to_id on the email using the values from the message" do
        resync_email_ids.call
        expect(existing_email.reload.in_reply_to_id).to eq("in-reply-to-id-5")
      end
    end
  end
end
