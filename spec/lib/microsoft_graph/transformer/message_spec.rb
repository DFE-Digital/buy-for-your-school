require "spec_helper"

describe MicrosoftGraph::Transformer::Message do
  describe "transformation into its resource" do
    it "maps response json field names to object fields" do
      payload = {
        "body" => { "content" => "c", "contentType" => "cT" },
        "bodyPreview" => "<p>Hello, World</p>",
        "conversationId" => "CONVID123",
        "from" => { "emailAddress" => { "address" => "d", "name" => "e" } },
        "id" => "AAMkAGmnprAAA=",
        "internetMessageId" => "<imid_AAMkAGmnprAAA@mail.gmail.com",
        "importance" => "high",
        "isRead" => true,
        "sentDateTime" => "2021-11-25T10:28:56Z",
        "subject" => "Important, please read",
        "toRecipients" => [
          { "emailAddress" => { "address" => "x", "name" => "y" } },
          { "emailAddress" => { "address" => "a", "name" => "b" } },
        ],
      }

      message = described_class.transform(payload, into: MicrosoftGraph::Resource::Message)

      expect(message.body.as_json).to match(
        MicrosoftGraph::Transformer::ItemBody.transform(payload["body"],
                                                        into: MicrosoftGraph::Resource::ItemBody).as_json,
      )
      expect(message.body_preview).to eq("<p>Hello, World</p>")
      expect(message.conversation_id).to eq("CONVID123")
      expect(message.from.as_json).to match(
        MicrosoftGraph::Transformer::Recipient.transform(payload["from"],
                                                         into: MicrosoftGraph::Resource::Recipient).as_json,
      )
      expect(message.id).to eq("AAMkAGmnprAAA=")
      expect(message.internet_message_id).to eq("<imid_AAMkAGmnprAAA@mail.gmail.com")
      expect(message.importance).to eq("high")
      expect(message.is_read).to eq(true)
      expect(message.sent_date_time).to eq(Time.zone.parse(payload["sentDateTime"]))
      expect(message.subject).to eq("Important, please read")
      expect(message.to_recipients.map(&:as_json)).to match(
        payload["toRecipients"]
          .map { |recipient|
            MicrosoftGraph::Transformer::Recipient.transform(recipient,
                                                             into: MicrosoftGraph::Resource::Recipient)
          }
          .map(&:as_json),
      )
    end
  end
end
