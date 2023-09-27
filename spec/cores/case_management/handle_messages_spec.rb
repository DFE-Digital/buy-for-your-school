require "rails_helper"

describe CaseManagement::HandleMessages do
  subject(:handler) { described_class.new }

  let(:support_case) { create(:support_case) }
  let(:support_email_id) { create(:support_email).id }

  describe "#received_email_attached_to_case" do
    it "creates an interaction for the incoming email" do
      payload = { support_case_id: support_case.id, support_email_id: }
      expect { handler.received_email_attached_to_case(payload) }.to change { support_case.reload.action_required }.from(false).to(true)
    end

    context "when the case is resolved already" do
      let(:support_case) { create(:support_case, :resolved) }

      it "reopens the case" do
        payload = { support_case_id: support_case.id, support_email_id: }
        expect { handler.received_email_attached_to_case(payload) }.to change { support_case.reload.state }.from("resolved").to("opened")
      end

      it "broadcasts the reopening of the case" do
        payload = { support_case_id: support_case.id, support_email_id: }

        with_event_handler(listening_to: :case_reopened_due_to_received_email) do |other_handler|
          handler.received_email_attached_to_case(payload)
          expect(other_handler).to have_received(:case_reopened_due_to_received_email).with(payload)
        end
      end
    end

    context "when the case is new" do
      let(:support_case) { create(:support_case, :initial) }

      it "does not reopen the case" do
        payload = { support_case_id: support_case.id, support_email_id: }
        expect { handler.received_email_attached_to_case(payload) }.to(not_change { support_case.reload.state })
      end

      it "does not broadcast the reopening of the case" do
        payload = { support_case_id: support_case.id, support_email_id: }

        with_event_handler(listening_to: :case_reopened_due_to_received_email) do |other_handler|
          handler.received_email_attached_to_case(payload)
          expect(other_handler).not_to have_received(:case_reopened_due_to_received_email).with(payload)
        end
      end
    end
  end

  describe "#contact_to_school_made" do
    context "when the case is initial and can be put on hold" do
      it "puts the case on hold" do
        payload = { support_case_id: support_case.id, contact_type: "logged phone call" }
        expect { handler.contact_to_school_made(payload) }.to change { support_case.reload.state }.from("initial").to("on_hold")
      end

      it "broadcasts the case_held_by_system event" do
        payload = { support_case_id: support_case.id, contact_type: "logged phone call" }
        new_payload = { support_case_id: support_case.id, reason: "logged phone call" }

        with_event_handler(listening_to: :case_held_by_system) do |other_handler|
          handler.contact_to_school_made(payload)
          expect(other_handler).to have_received(:case_held_by_system).with(new_payload)
        end
      end
    end
  end
end
