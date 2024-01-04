require "rails_helper"

describe Support::Agent::Notifyable do
  subject(:agent) { create(:support_agent) }

  describe "assigned_to_notifications#mark_as_read" do
    let(:another_agent) { create(:support_agent) }
    let!(:unread_notification1) { create(:support_notification, :case_assigned, :unread, assigned_to: agent) }
    let!(:unread_notification2) { create(:support_notification, :case_assigned, :unread, assigned_to: agent) }
    let!(:read_notification) { create(:support_notification, :case_assigned, :read, read_at: Time.zone.parse("01/01/2023 10:00"), assigned_to: agent) }
    let!(:another_agents_notification) { create(:support_notification, :case_assigned, :unread, assigned_to: another_agent) }

    describe "marking notifications as read" do
      it "marks all the agents notifications as read" do
        agent.assigned_to_notifications.mark_as_read

        expect(unread_notification1.reload.read).to be(true)
        expect(unread_notification1.read_at).to be_within(1.second).of(Time.zone.now)

        expect(unread_notification2.reload.read).to be(true)
        expect(unread_notification2.read_at).to be_within(1.second).of(Time.zone.now)
      end

      it "does not modify already read notifications" do
        expect { agent.assigned_to_notifications.mark_as_read }.not_to \
          change { read_notification.reload.read_at }.from(Time.zone.parse("01/01/2023 10:00"))
      end

      it "does not modify other agents notifications" do
        expect { agent.assigned_to_notifications.mark_as_read }.not_to \
          change { another_agents_notification.reload.read }.from(false)
      end
    end
  end
end
