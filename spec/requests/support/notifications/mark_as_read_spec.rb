require "rails_helper"

describe "Marking notifications as read/unread" do
  before do
    agent_is_signed_in
  end

  let(:notificaction) { create(:support_notification, :unread) }

  describe "marking notifications as read" do
    it "redirects back to notifications with the notification now marked as read" do
      post support_notification_read_path(notificaction)
      expect(notificaction.reload.read).to be(true)
      expect(response).to redirect_to(support_notifications_path)
    end
  end
end
