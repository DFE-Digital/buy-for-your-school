require "rails_helper"

describe "Marking notifications as read/unread" do
  before { agent_is_signed_in }

  let(:notificaction) { create(:support_notification, :case_assigned, :read) }

  describe "marking notifications as read" do
    it "marks the notification marked as read" do
      post support_notification_read_path(notificaction)
      expect(notificaction.reload.read).to be(true)
      expect(notificaction.read_at).to be_within(1.second).of(Time.zone.now)
    end
  end

  describe "marking notifications as unread" do
    it "marks the notification as unread" do
      post support_notification_read_path(notificaction, mark_as: :unread)
      expect(notificaction.reload.read).to be(false)
      expect(notificaction.read_at).to be(nil)
    end
  end

  describe "redirection" do
    context "when no redirection param is specified" do
      it "redirects back to notifications" do
        post support_notification_read_path(notificaction)
        expect(response).to redirect_to(support_notifications_path)
      end
    end

    context "when redirection param is for a path the system does not recognise" do
      it "redirects to the notifications list" do
        post support_notification_read_path(notificaction, redirect_to: "/etc/hosts")
        expect(response).to redirect_to(support_notifications_path)
      end
    end

    context "when redirection param is for a path the system does recognise" do
      it "redirects to the specified path" do
        post support_notification_read_path(notificaction, redirect_to: root_path)
        expect(response).to redirect_to(root_path)
      end
    end
  end
end
