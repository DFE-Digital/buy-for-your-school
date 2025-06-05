require "rails_helper"

describe "Marking All notifications as read/unread" do
  before { cec_agent_is_signed_in(agent:) }

  let(:agent) { create(:support_agent) }
  let!(:notification1) { create(:support_notification, :case_assigned, :unread, assigned_to: agent) }

  describe "marking notifications as read" do
    it "redirects back to notifications" do
      post cec_notifications_mark_all_read_path
      expect(response).to redirect_to(cec_notifications_path)
    end

    it "marks all the agents notifications as read" do
      post cec_notifications_mark_all_read_path
      expect(notification1.reload.read).to be(true)
    end
  end
end
