require "rails_helper"

describe Messages::SendNewMessage do
  def send_new_message! = described_class.new.call(support_case_id: support_case.id, message_options:)

  let(:support_case) { create(:support_case) }
  let(:send_new_message_service) { double("send_new_message_service") }
  let(:message_options) do
    {
      sender: build(:support_agent),
      file_attachments: [{ name: "attachment" }],
      to_recipients: ["to@email.com"],
      cc_recipients: ["cc@email.com"],
      bcc_recipients: ["bcc@email.com"],
      message_text: "this is a message",
      subject: "subject",
    }
  end

  before do
    allow(Support::Messages::Outlook::SendNewMessage).to receive(:new).with(**message_options).and_return(send_new_message_service)
    allow(send_new_message_service).to receive(:call)
  end

  it "calls the SendNewMessage service" do
    send_new_message!

    expect(Support::Messages::Outlook::SendNewMessage).to have_received(:new).with(**message_options)
    expect(send_new_message_service).to have_received(:call)
  end

  it "broadcasts the contact_to_school_made event" do
    with_event_handler(listening_to: :contact_to_school_made) do |handler|
      send_new_message!
      expect(handler).to have_received(:contact_to_school_made).with({ support_case_id: support_case.id, contact_type: "sending a new message" })
    end
  end
end
