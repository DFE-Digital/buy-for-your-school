require "rails_helper"

describe "Marking notifications as read/unread" do
  before { agent_is_signed_in }

  describe "marking notifications as read" do
    let(:notificaction) { create(:support_notification, :case_assigned, :unread) }

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

  describe "marking notifications as unread" do
    let(:notificaction) { create(:support_notification, :case_assigned, :read) }

    it "redirects back to notifications with the notification now marked as unread" do
      post support_notification_read_path(notificaction, mark_as: :unread)
      expect(notificaction.reload.read).to be(false)
      expect(response).to redirect_to(support_notifications_path)
    end
  end
end
