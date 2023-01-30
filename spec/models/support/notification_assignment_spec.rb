require "rails_helper"

describe Support::NotificationAssignment do
  describe "Agent's notification feed" do
    let(:agent) { create(:support_agent) }
    let(:other_agent) { create(:support_agent) }

    it "returns all assigned notifications for that agent" do
      described_class.assign(notification: build(:support_notification, body: "Notification A"), to: agent, assigned_by: other_agent)
      described_class.assign(notification: build(:support_notification, body: "Notification B"), to: agent, assigned_by: other_agent)
      described_class.assign(notification: build(:support_notification, body: "Notification C"), to: other_agent, assigned_by: agent)

      notification_feed = described_class.feed(agent:)

      expect(notification_feed.pluck(:body)).to eq(["Notification B", "Notification A"])
    end

    describe "marking a notification as read" do
      it "sets read flag and read_at time to now" do
        assignment = described_class.assign(notification: build(:support_notification, body: "Notification A"), to: agent, assigned_by: other_agent)
        assignment.mark_as_read!
        assignment.reload
        expect(assignment).to be_read
        expect(assignment.read_at).to be_within(1.second).of(Time.zone.now)
      end
    end
  end
end
