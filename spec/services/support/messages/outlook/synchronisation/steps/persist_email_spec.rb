require "rails_helper"

describe Support::Messages::Outlook::Synchronisation::Steps::PersistEmail do
  let(:email)       { create(:support_email) }
  let(:is_in_inbox) { true }
  let(:message)     do
    double(
      inbox?: is_in_inbox,
      sender: { name: "Sender", address: "sender@email.com" },
      recipients: %w[1 2],
      conversation_id: "123",
      subject: "Subject Line",
      body: double(content: "Email body content"),
      received_date_time: Time.zone.parse("01/01/2022 10:32"),
      sent_date_time: Time.zone.parse("01/01/2022 10:30"),
    )
  end

  it "sets the corresponding fields on the email from the message" do
    described_class.call(message, email)

    email.reload

    expect(email.sender).to eq({ "name" => "Sender", "address" => "sender@email.com" })
    expect(email.recipients).to eq(%w[1 2])
    expect(email.outlook_conversation_id).to eq("123")
    expect(email.subject).to eq("Subject Line")
    expect(email.received_at).to eq(Time.zone.parse("01/01/2022 10:32"))
    expect(email.sent_at).to eq(Time.zone.parse("01/01/2022 10:30"))
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
