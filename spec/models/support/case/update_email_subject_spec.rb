require "rails_helper"

RSpec.describe Support::Case::UpdateEmailSubject do
  subject(:service) do
    described_class.new(email:, kase:, mailbox:)
  end

  let(:email_subject) { "Original subject" }
  let(:email) { create(:email, subject: email_subject, body: "Original body", outlook_id: "outlook-message-id") }
  let(:kase) { create(:support_case, ref: "000123") }
  let(:mailbox) { Email.default_mailbox }
  let(:graph_client) { instance_double(MicrosoftGraph::Client) }
  let(:new_subject) { "Case: #{kase.ref} - #{email_subject}" }

  describe "#call" do
    before do
      allow(MicrosoftGraph).to receive(:client).and_return(graph_client)
      allow(graph_client).to receive(:update_message)
      service.call
    end

    it "updates the email subject on Microsoft Graph" do
      expect(graph_client).to have_received(:update_message).with(
        user_id: mailbox.user_id,
        message_id: email.outlook_id,
        details: { subject: new_subject },
      )
    end

    it "updates the local email subject" do
      expect(email.subject).to eq(new_subject)
    end
  end
end
