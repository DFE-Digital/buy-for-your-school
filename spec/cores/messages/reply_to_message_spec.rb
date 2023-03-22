require "rails_helper"

describe Messages::ReplyToMessage do
  def reply_to_message! = described_class.new.call(support_case_id: support_case.id, reply_options:)

  let(:support_case) { create(:support_case) }
  let(:send_reply_to_email_service) { double("send_reply_to_email_service") }
  let(:reply_options) do
    {
      reply_to_email: build(:support_email),
      reply_text: "this is a reply",
      sender: build(:support_agent),
      file_attachments: [{ name: "attachment" }],
    }
  end

  before do
    allow(Support::Messages::Outlook::SendReplyToEmail).to receive(:new).with(**reply_options).and_return(send_reply_to_email_service)
    allow(send_reply_to_email_service).to receive(:call)
  end

  it "calls the SendReplyToEmail service" do
    reply_to_message!

    expect(Support::Messages::Outlook::SendReplyToEmail).to have_received(:new).with(**reply_options)
    expect(send_reply_to_email_service).to have_received(:call)
  end

  it "broadcasts the contact_to_school_made event" do
    with_event_handler(listening_to: :contact_to_school_made) do |handler|
      reply_to_message!
      expect(handler).to have_received(:contact_to_school_made).with({ support_case_id: support_case.id, contact_type: "replying to a message" })
    end
  end
end
