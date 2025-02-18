require "rails_helper"

describe "Marking All notifications as read/unread" do
  before { agent_is_signed_in(agent:) }

  let(:agent) { create(:support_agent) }
  let!(:notification1) { create(:support_notification, :case_assigned, :unread, assigned_to: agent) }

  describe "marking notifications as read" do
    it "redirects back to notifications" do
      post support_notifications_mark_all_read_path
      expect(response).to redirect_to(support_notifications_path)
    end

    it "marks all the agents notifications as read" do
      post support_notifications_mark_all_read_path
      expect(notification1.reload.read).to be(true)
    end
  end
end
