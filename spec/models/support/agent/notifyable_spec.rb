require "rails_helper"

describe Support::Agent::Notifyable do
  subject(:agent) { create(:support_agent) }

  describe "assigned_to_notifications#mark_as_read" do
    let(:another_agent) { create(:support_agent) }
    let!(:another_agents_notification) { create(:support_notification, :case_assigned, :unread, assigned_to: another_agent) }

    describe "marking notifications as read" do
      it "does not modify other agents notifications" do
        expect { agent.assigned_to_notifications.mark_as_read }.not_to \
          change { another_agents_notification.reload.read }.from(false)
      end
    end
  end

  describe "#notify_assigned_to_case" do
    context "when assigning case to yourself" do
      it "does not create a new notifcation" do
        support_case = create(:support_case)
        expect { agent.notify_assigned_to_case(support_case:, assigned_by: agent) }
          .not_to(change(Support::Notification, :count))
      end
    end
  end
end
