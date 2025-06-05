require "rails_helper"

describe "Marking notifications as read/unread" do
  before { cec_agent_is_signed_in(agent:) }

  let(:agent) { create(:support_agent) }
  let(:notification) { create(:support_notification, :case_assigned, :read) }

  describe "marking notifications as read" do
    it "marks the notification marked as read" do
      post cec_notification_read_path(notification)
      expect(notification.reload.read).to be(true)
      expect(notification.read_at).to be_within(1.second).of(Time.zone.now)
    end
  end

  describe "marking notifications as unread" do
    it "marks the notification as unread" do
      post cec_notification_read_path(notification, mark_as: :unread)
      expect(notification.reload.read).to be(false)
      expect(notification.read_at).to be_nil
    end
  end

  describe "redirection" do
    context "when no redirection param is specified" do
      it "redirects back to notifications" do
        post cec_notification_read_path(notification)
        expect(response).to redirect_to(cec_notifications_path)
      end
    end

    context "when redirection param is for a path the system does not recognise" do
      it "redirects to the notifications list" do
        post cec_notification_read_path(notification, redirect_to: "/etc/hosts")
        expect(response).to redirect_to(cec_notifications_path)
      end
    end

    context "when redirection param is for a path the system does recognise" do
      it "redirects to the specified path" do
        post cec_notification_read_path(notification, redirect_to: root_path)
        expect(response).to redirect_to(root_path)
      end
    end
  end
end
