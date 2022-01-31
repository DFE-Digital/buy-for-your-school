describe Support::GetEmailAttachmentsJob do
  subject(:job) { described_class.new }

  let(:email) { create(:support_email) }

  describe "#perform" do
    it "downloads email attachments for given email id" do
      allow(Support::IncomingEmails::EmailAttachments).to receive(:download)

      job.perform(email.id)

      expect(Support::IncomingEmails::EmailAttachments).to have_received(:download)
                                                          .with(email: email).once
    end
  end
end
