require "rails_helper"

describe "Updating email read status" do
  before { agent_is_signed_in }

  context "when marking an email as read" do
    let(:support_case) { create(:support_case) }
    let!(:email) { create(:support_email, case: support_case) }

    it "marks the email as read" do
      patch support_email_read_status_path(email, status: "read")
      expect(email.reload.is_read).to be(true)
    end

    context "when the case is marked as action required" do
      let(:support_case) { create(:support_case, :action_required) }

      context "when there are other unread emails on the case" do
        before { create(:support_email, case: support_case, is_read: false) }

        specify "the case remains action reqired" do
          patch support_email_read_status_path(email, status: "read")
          expect(support_case.reload).to be_action_required
        end
      end

      context "when there are no more unread emails on the case" do
        before { create(:support_email, case: support_case, is_read: true) }

        specify "the case is no longer action required" do
          patch support_email_read_status_path(email, status: "read")
          expect(support_case.reload).not_to be_action_required
        end
      end
    end
  end

  context "when marking an email as unread" do
    let!(:email) { create(:support_email) }

    it "marks the email as unread" do
      patch support_email_read_status_path(email, status: "unread")
      expect(email.reload.is_read).to be(false)
    end
  end
end
