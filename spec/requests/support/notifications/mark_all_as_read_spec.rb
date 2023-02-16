require "rails_helper"

describe "Marking All notifications as read/unread" do
  before { agent_is_signed_in(agent:) }

  let(:agent) { create(:support_agent) }
  let(:another_agent) { create(:support_agent) }
  let!(:notificaction1) { create(:support_notification, :case_assigned, :unread, assigned_to: agent) }
  let!(:notificaction2) { create(:support_notification, :case_assigned, :read, read_at: Time.zone.parse("01/01/2023 10:00"), assigned_to: agent) }
  let!(:notificaction3) { create(:support_notification, :case_assigned, :unread, assigned_to: agent) }
  let!(:notificaction4) { create(:support_notification, :case_assigned, :unread, assigned_to: another_agent) }

  describe "marking notifications as read" do
    it "redirects back to notifications" do
      post support_notifications_mark_all_read_path
      expect(response).to redirect_to(support_notifications_path)
    end

    it "marks all the agents notifications as read" do
      post support_notifications_mark_all_read_path

      expect(notificaction1.reload.read).to be(true)
      expect(notificaction1.read_at).to be_within(1.second).of(Time.zone.now)

      expect(notificaction3.reload.read).to be(true)
      expect(notificaction3.read_at).to be_within(1.second).of(Time.zone.now)

      expect(notificaction3.reload.read).to be(true)
      expect(notificaction3.read_at).to be_within(1.second).of(Time.zone.now)
    end

    it "does not modify already read notifications" do
      expect { post support_notifications_mark_all_read_path }.not_to change { notificaction2.reload.read_at }.from(Time.zone.parse("01/01/2023 10:00"))
    end

    it "does not modify other agents notifications" do
      expect { post support_notifications_mark_all_read_path }.not_to change { notificaction4.reload.read }.from(false)
    end
  end
end
