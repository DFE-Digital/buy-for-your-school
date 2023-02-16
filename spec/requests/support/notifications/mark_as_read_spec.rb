require "rails_helper"

describe "Marking notifications as read/unread" do
  before do
    agent_is_signed_in
  end

  let(:notificaction) { create(:support_notification, :case_assigned, :unread) }

  describe "marking notifications as read" do
    it "redirects back to notifications with the notification now marked as read" do
      post support_notification_read_path(notificaction)
      expect(notificaction.reload.read).to be(true)
      expect(response).to redirect_to(support_notifications_path)
    end

    context "with a redirect param" do
      it "redirects to the specified path with the notification now marked as read" do
        post support_notification_read_path(notificaction, redirect_to: support_cases_path)
        expect(notificaction.reload.read).to be(true)
        expect(response).to redirect_to(support_cases_path)
      end
    end
  end
end
