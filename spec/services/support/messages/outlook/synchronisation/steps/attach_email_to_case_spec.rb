require "rails_helper"

describe Support::Messages::Outlook::Synchronisation::Steps::AttachEmailToCase do
  let(:email)   { create(:support_email, case: assigned_case) }
  let(:message) { double(inbox?: true) }

  context "when the email is not already attached to a case" do
    let(:assigned_case) { nil }
    let(:detected_case) { create(:support_case) }

    before do
      allow_any_instance_of(Support::Messages::Outlook::Synchronisation::MessageCaseDetection)
        .to receive(:detect_existing_or_create_new_case).and_return(detected_case)
    end

    it "assigns the email detected case" do
      described_class.call(message, email)
      expect(email.reload.case).to eq(detected_case)
    end

    context "with incoming email" do
      it "broadcasts an event to indicate the incoming email has been assigned to a case" do
        with_event_handler(listening_to: :received_email_attached_to_case) do |handler|
          described_class.call(message, email)

          expect(handler).to have_received(:received_email_attached_to_case).with({
            support_email_id: email.id,
            support_case_id: email.reload.case_id
          })
        end
      end
    end

    context "with outgoing email" do
      let(:message) { double(inbox?: false) }

      it "broadcasts an event to indicate the outgoing email has been assigned to a case" do
        with_event_handler(listening_to: :sent_email_attached_to_case) do |handler|
          described_class.call(message, email)

          expect(handler).to have_received(:sent_email_attached_to_case).with({
            support_email_id: email.id,
            support_case_id: email.reload.case_id
          })
        end
      end
    end

    context "when detected case is resolved" do
      let(:detected_case) { create(:support_case, :resolved) }

      context "when the message is incoming" do
        let(:message) { double(inbox?: true) }

        it "re-opens the case" do
          described_class.call(message, email)
          expect(detected_case.reload).to be_opened
        end
      end

      context "when message is not incoming" do
        let(:message) { double(inbox?: false) }

        it "does not re-open the case" do
          described_class.call(message, email)

          expect(detected_case.reload).not_to be_opened
        end
      end
    end

    context "when detected case is closed" do
      let(:detected_case) { create(:support_case, :closed) }

      it "creates a new case and assigns the email to that" do
        newly_created_case = build(:support_case)

        allow_any_instance_of(Support::Messages::Outlook::Synchronisation::MessageCaseDetection)
          .to receive(:new_case).and_return(newly_created_case)

        described_class.call(message, email)

        expect(email.reload.case).to eq(newly_created_case)
      end
    end
  end

  context "when the email is already attached to a case" do
    let(:assigned_case) { create(:support_case) }

    it "does not broadcast an event" do
      with_event_handler(listening_to: [:received_email_attached_to_case, :sent_email_attached_to_case]) do |handler|
        described_class.call(message, email)

        expect(handler).not_to have_received(:received_email_attached_to_case)
        expect(handler).not_to have_received(:sent_email_attached_to_case)
      end
    end

    it "keeps the existing case assigned" do
      described_class.call(message, email)

      expect(email.reload.case).to eq(assigned_case)
    end

    context "when assigned case is resolved" do
      let(:assigned_case) { create(:support_case, :resolved) }

      it "re-opens the case" do
        described_class.call(message, email)

        expect(email.reload.case).to eq(assigned_case)
        expect(email.case.reload).to be_opened
      end
    end

    context "when assigned case is closed" do
      let(:assigned_case) { create(:support_case, :closed) }

      it "creates a new case and assigns the email to that" do
        newly_created_case = build(:support_case)

        allow_any_instance_of(Support::Messages::Outlook::Synchronisation::MessageCaseDetection)
          .to receive(:new_case).and_return(newly_created_case)

        described_class.call(message, email)

        expect(email.reload.case).to eq(newly_created_case)
      end
    end
  end
end
