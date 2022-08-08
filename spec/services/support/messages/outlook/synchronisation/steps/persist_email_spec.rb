require "rails_helper"

describe Support::Messages::Outlook::Synchronisation::Steps::PersistEmail do
  let(:email)       { create(:support_email) }
  let(:is_in_inbox) { true }
  let(:message)     do
    double(
      id: "345",
      inbox?: is_in_inbox,
      sender: { name: "Sender", address: "sender@email.com" },
      recipients: %w[1 2],
      conversation_id: "123",
      subject: "Subject Line",
      body: double(content: "Unique Body, Reply Body"),
      unique_body: double(content: "Unique Body"),
      received_date_time: Time.zone.parse("01/01/2022 10:32"),
      sent_date_time: Time.zone.parse("01/01/2022 10:30"),
      is_draft: true,
      is_read: false,
      has_attachments: true,
      case_reference_from_headers: "000888",
      in_reply_to_id: "IMID-2",
    )
  end

  it "sets the corresponding fields on the email from the message" do
    described_class.call(message, email)

    email.reload

    expect(email.sender).to eq({ "name" => "Sender", "address" => "sender@email.com" })
    expect(email.recipients).to eq(%w[1 2])
    expect(email.subject).to eq("Subject Line")
    expect(email.outlook_id).to eq("345")
    expect(email.outlook_conversation_id).to eq("123")
    expect(email.outlook_is_read).to eq(false)
    expect(email.outlook_is_draft).to eq(true)
    expect(email.outlook_has_attachments).to eq(true)
    expect(email.outlook_received_at).to eq(Time.zone.parse("01/01/2022 10:32"))
    expect(email.sent_at).to eq(Time.zone.parse("01/01/2022 10:30"))
    expect(email.in_reply_to_id).to eq("IMID-2")
    expect(email.body).to eq("Unique Body, Reply Body")
    expect(email.unique_body).to eq("Unique Body")
  end

  context "when message is coming from the inbox mail folder" do
    let(:is_in_inbox) { true }

    it "sets the email folder to be inbox" do
      described_class.call(message, email)

      expect(email.reload.folder).to eq("inbox")
    end
  end

  context "when message is coming from the sent items mail folder" do
    let(:is_in_inbox) { false }

    it "sets the email folder to be inbox" do
      described_class.call(message, email)

      expect(email.reload.folder).to eq("sent_items")
    end
  end
end
