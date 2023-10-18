require "rails_helper"

describe CaseManagement::HandleMessages do
  subject(:handler) { described_class.new }

  let(:support_case) { create(:support_case) }
  let(:support_email_id) { create(:support_email).id }

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
