require "rails_helper"

describe "Updating email read status" do
  before { cec_agent_is_signed_in(agent:) }

  context "when marking an email as read" do
    let(:agent) { create(:support_agent) }
    let(:support_case) { create(:support_case) }
    let!(:email) { create(:support_email, ticket: support_case) }

    it "marks the email as read" do
      patch cec_email_read_status_path(email, status: "read")
      expect(email.reload.is_read).to be(true)
    end
  end

  context "when marking an email as unread" do
    let(:agent) { create(:support_agent) }
    let(:support_case) { create(:support_case) }
    let!(:email) { create(:support_email, ticket: support_case) }

    it "marks the email as unread" do
      patch cec_email_read_status_path(email, status: "unread")
      expect(email.reload.is_read).to be(false)
    end
  end
end
