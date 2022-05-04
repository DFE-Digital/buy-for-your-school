require "rails_helper"

describe Support::Messages::Outlook::SynchroniseMailFolder do
  let(:message_1) { double("message_1") }
  let(:message_2) { double("message_2") }
  let(:message_3) { double("message_3") }

  before { allow(Support::Messages::Outlook::SynchroniseMessage).to receive(:call) }

  context "when the mail folder has messages to synchronise" do
    let(:mail_folder) { double("mail_folder-with messages", recent_messages: [message_1, message_2, message_3]) }

    it "synchronises each message" do
      described_class.call(mail_folder)

      expect(Support::Messages::Outlook::SynchroniseMessage).to have_received(:call).with(message_1)
      expect(Support::Messages::Outlook::SynchroniseMessage).to have_received(:call).with(message_2)
      expect(Support::Messages::Outlook::SynchroniseMessage).to have_received(:call).with(message_3)
    end
  end

  context "when there are no messages to syncronise" do
    let(:mail_folder) { double("mail_folder-without messages", recent_messages: []) }

    it "does not synchronise anything" do
      described_class.call(mail_folder)

      expect(Support::Messages::Outlook::SynchroniseMessage).not_to have_received(:call)
    end
  end
end
