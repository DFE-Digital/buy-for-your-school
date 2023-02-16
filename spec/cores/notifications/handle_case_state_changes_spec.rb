require "rails_helper"

describe Notifications::HandleCaseStateChanges do
  subject(:handler) { described_class.new }

  describe "#agent_assigned_to_case" do
    let(:support_case_id) { create(:support_case).id }
    let(:assigned_by_agent_id) { create(:support_agent).id }
    let(:assigned_to_agent_id) { create(:support_agent).id }

    it "sends a notificaction for the assignment to the assigned agent" do
      payload = { support_case_id:, assigned_by_agent_id:, assigned_to_agent_id: }
      expect { handler.agent_assigned_to_case(payload) }.to change { Support::Notification.case_assigned.where(support_case_id:, assigned_by_id: assigned_by_agent_id, assigned_to_id: assigned_to_agent_id).count }.from(0).to(1)
    end

    context "when agent assigns themselves to the case" do
      it "does not send a notification at all" do
        payload = { support_case_id:, assigned_by_agent_id: assigned_to_agent_id, assigned_to_agent_id: }
        expect { handler.agent_assigned_to_case(payload) }.not_to change(Support::Notification, :count)
      end
    end
  end
end
