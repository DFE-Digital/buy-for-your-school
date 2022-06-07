require "rails_helper"

describe Support::SynchronizeSharedInboxJob do
  subject(:job) { described_class.new }

  describe "#perform" do
    it "synchronizes emails from the last 15 minutes for inbox and sent items" do
      allow(Support::Messages::Outlook::SynchroniseMailFolder).to receive(:call).and_return(nil)

      mail_folder_inbox = double("mail_folder_inbox")
      allow(Support::Messages::Outlook::MailFolder)
        .to receive(:new).with(messages_after: within(1.second).of(15.minutes.ago), folder: :inbox)
        .and_return(mail_folder_inbox)

      mail_folder_sent_items = double("mail_folder_sent_items")
      allow(Support::Messages::Outlook::MailFolder)
        .to receive(:new).with(messages_after: within(1.second).of(15.minutes.ago), folder: :sent_items)
        .and_return(mail_folder_sent_items)

      job.perform

      expect(Support::Messages::Outlook::SynchroniseMailFolder).to have_received(:call).with(mail_folder_inbox).once
      expect(Support::Messages::Outlook::SynchroniseMailFolder).to have_received(:call).with(mail_folder_sent_items).once
    end
  end
end
