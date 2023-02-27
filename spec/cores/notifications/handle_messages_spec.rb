require "rails_helper"

describe Notifications::HandleMessages do
  subject(:handler) { described_class.new }

  describe "#received_email_attached_to_case" do
    let(:support_case) { create(:support_case) }
    let(:support_email) { create(:support_email, outlook_received_at: 1.minute.ago) }

    context "when email was received today" do
      it "creates a notification for the agent on the emails case" do
        payload = { support_case_id: support_case.id, support_email_id: support_email.id }
        expect { handler.received_email_attached_to_case(payload) }.to change {
          Support::Notification.case_email_recieved.where(
            support_case:,
            assigned_to: support_case.agent,
            subject: support_email,
            assigned_by_system: true,
            created_at: support_email.outlook_received_at,
          ).count
        }.from(0).to(1)
      end
    end

    context "when email was received earlier than today" do
      let(:support_email) { create(:support_email, outlook_received_at: 25.hours.ago) }

      it "doesnt create any notifications" do
        payload = { support_case_id: support_case.id, support_email_id: support_email.id }
        expect { handler.received_email_attached_to_case(payload) }.not_to change(Support::Notification, :count).from(0)
      end
    end

    context "when the case is not assigned to anyone" do
      let(:support_case) { create(:support_case, agent: nil) }

      it "doesnt create any notifications" do
        payload = { support_case_id: support_case.id, support_email_id: support_email.id }
        expect { handler.received_email_attached_to_case(payload) }.not_to change(Support::Notification, :count).from(0)
      end
    end
  end
end
