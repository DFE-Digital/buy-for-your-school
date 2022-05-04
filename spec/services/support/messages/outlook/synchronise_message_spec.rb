require "rails_helper"

describe Support::Messages::Outlook::SynchroniseMessage do
  before do
    allow(Support::Messages::Outlook::Synchronisation::Steps::PersistEmail).to receive(:call).and_return(nil)
    allow(Support::Messages::Outlook::Synchronisation::Steps::AttachEmailToCase).to receive(:call).and_return(nil)
    allow(Support::Messages::Outlook::Synchronisation::Steps::PersistEmailAttachments).to receive(:call).and_return(nil)
    allow(Support::Messages::Outlook::Synchronisation::Steps::SurfaceEmailOnCase).to receive(:call).and_return(nil)
  end

  let(:message) { double("message", id: "123") }

  context "when this message has already been persisted" do
    before { create(:support_email, outlook_id: "123") }

    it "does not run any synchronisation for the message" do
      described_class.call(message)

      expect(Support::Messages::Outlook::Synchronisation::Steps::PersistEmail).not_to have_received(:call)
      expect(Support::Messages::Outlook::Synchronisation::Steps::AttachEmailToCase).not_to have_received(:call)
      expect(Support::Messages::Outlook::Synchronisation::Steps::PersistEmailAttachments).not_to have_received(:call)
      expect(Support::Messages::Outlook::Synchronisation::Steps::SurfaceEmailOnCase).not_to have_received(:call)
    end
  end

  context "when this message has not yet been persisted" do
    let(:email) { build(:support_email) }

    before { allow(Support::Email).to receive(:find_or_initialize_by).with(outlook_id: "123").and_return(email) }

    it "calls each step of the synchronisation process with the message and new email record" do
      described_class.call(message)

      expect(Support::Messages::Outlook::Synchronisation::Steps::PersistEmail).to have_received(:call).with(message, email)
      expect(Support::Messages::Outlook::Synchronisation::Steps::AttachEmailToCase).to have_received(:call).with(message, email)
      expect(Support::Messages::Outlook::Synchronisation::Steps::PersistEmailAttachments).to have_received(:call).with(message, email)
      expect(Support::Messages::Outlook::Synchronisation::Steps::SurfaceEmailOnCase).to have_received(:call).with(message, email)
    end
  end
end
