require "rails_helper"

RSpec.describe Support::Case::UpdateEmailSubject do
  subject(:service) do
    described_class.new(email_ids:, to_case_id: kase.id, mailbox:)
  end

  let(:email_subject) { "Original subject" }
  let(:email) { create(:email, subject: email_subject, body: "Original body", outlook_id: "outlook-message-id") }
  let(:email_ids) { [email.id] }
  let(:kase) { create(:support_case, ref: "000123") }
  let(:mailbox) { Email.default_mailbox }
  let(:graph_client) { instance_double(MicrosoftGraph::Client) }
  let(:new_subject) { "Case #{kase.ref} - #{email_subject}" }

  describe "#call" do
    before do
      kase.emails << email
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

    describe "incoming emails" do
      context "when the email subject does not contains a case reference" do
        let(:email_subject) { "Original subject" }

        it "updates the email subject with a case reference" do
          expect(email.reload.subject).to eq(new_subject)
        end
      end

      context "when the email subject already contains a case reference" do
        let(:email_subject) { "Case #{kase.ref} - Original subject" }

        it "does not update the email subject" do
          expect(email.reload.subject).to eq(email_subject)
        end
      end
    end

    describe "merge support cases" do
      # This tests the scenario when we move/merge emails from one case to another existing case,
      # and we want to update the email subject to reflect the old case reference
      # Basically new email subject updated with old case reference instead of new case reference

      context "when merge new case to existing case" do
        let(:new_email_subject) { "Another subject" }
        let(:new_email) { create(:email, subject: new_email_subject, body: "Original body", outlook_id: "outlook-message-id2") }

        let(:email_ids) { [new_email.id] }
        let(:new_kase) { create(:support_case, ref: "000456") }
        let(:updated_subject) { "Case #{kase.ref} - #{new_email_subject}" }

        before do
          new_kase.emails << new_email
        end

        it "move emails to existing case and updates the email subject with a existing case reference" do
          expect(new_email.reload.subject).to eq(updated_subject)
        end
      end
    end
  end
end
