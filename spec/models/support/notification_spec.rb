require "rails_helper"

describe Support::Notification do
  describe ".mark_as_read" do
    let(:another_agent) { create(:support_agent) }
    let!(:unread_notification1) { create(:support_notification, :case_assigned, :unread) }
    let!(:unread_notification2) { create(:support_notification, :case_assigned, :unread) }
    let!(:other_type_of_notification) { create(:support_notification, :case_email_received, :unread) }
    let!(:read_notification) { create(:support_notification, :case_assigned, :read, read_at: Time.zone.parse("01/01/2023 10:00")) }

    describe "marking notifications as read" do
      it "marks all the unread notifications as read" do
        described_class.case_assigned.mark_as_read

        expect(unread_notification1.reload.read).to be(true)
        expect(unread_notification1.read_at).to be_within(1.second).of(Time.zone.now)

        expect(unread_notification2.reload.read).to be(true)
        expect(unread_notification2.read_at).to be_within(1.second).of(Time.zone.now)
      end

      it "does not modify already read notifications" do
        expect { described_class.case_assigned.mark_as_read }.not_to \
          change { read_notification.reload.read_at }.from(Time.zone.parse("01/01/2023 10:00"))
      end

      it "respects the scopes and does not modify other types of notifications" do
        expect { described_class.case_assigned.mark_as_read }.not_to(change { other_type_of_notification.reload.read })
      end
    end
  end
end
