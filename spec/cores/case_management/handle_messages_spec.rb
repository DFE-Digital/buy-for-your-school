require "rails_helper"

describe CaseManagement::HandleMessages do
  subject(:handler) { described_class.new }

  let(:support_case) { create(:support_case) }
  let(:support_email_id) { create(:support_email).id }

  describe "#received_email_attached_to_case" do
    it "creates an interaction for the incoming email" do
      payload = { support_case_id: support_case.id, support_email_id:, initial_sync: true }
      expect { handler.received_email_attached_to_case(payload) }.to change { support_case.reload.action_required }.from(false).to(true)
    end
  end
end
