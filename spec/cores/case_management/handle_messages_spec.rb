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
  end
end
