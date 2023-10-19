require "rails_helper"

describe "Updating email read status" do
  before { agent_is_signed_in }

  context "when marking an email as read" do
    let(:support_case) { create(:support_case) }
    let!(:email) { create(:support_email, ticket: support_case) }

    it "marks the email as read" do
      patch support_email_read_status_path(email, status: "read")
      expect(email.reload.is_read).to be(true)
    end

    context "when the case is currently marked as action required" do
      let(:support_case) { create(:support_case, :action_required) }

      context "when there are other unread emails in the inbox" do
        before { create(:support_email, :inbox, case: support_case, is_read: false) }

        specify "then the case remains as action required" do
          patch support_email_read_status_path(email, status: "read")
          expect(support_case.reload).to be_action_required
        end
      end

      context "when there are other unread emails in the sent items folder" do
        before { create(:support_email, :sent_items, case: support_case, is_read: false) }

        specify "then the case is not longer marked as action required" do
          patch support_email_read_status_path(email, status: "read")
          expect(support_case.reload).not_to be_action_required
        end
      end

      context "when there are no unread emails in the inbox but there are unread sent items" do
        before do
          create(:support_email, :inbox, case: support_case, is_read: true)
          create(:support_email, :sent_items, case: support_case, is_read: false)
        end

        specify "then the case is not longer marked as action required" do
          patch support_email_read_status_path(email, status: "read")
          expect(support_case.reload).not_to be_action_required
        end
      end
    end
  end

  context "when marking an email as unread" do
    let(:support_case) { create(:support_case) }
    let!(:email) { create(:support_email, ticket: support_case) }

    it "marks the email as unread" do
      patch support_email_read_status_path(email, status: "unread")
      expect(email.reload.is_read).to be(false)
    end

    context "when the case is not currently marked as action required" do
      let(:support_case) { create(:support_case, action_required: true) }

      context "when there are other unread emails in the inbox" do
        before { create(:support_email, :inbox, case: support_case, is_read: false) }

        specify "then the case remains as action required" do
          patch support_email_read_status_path(email, status: "read")
          expect(support_case.reload).to be_action_required
        end
      end

      context "when there are other unread emails in the sent items folder" do
        before { create(:support_email, :sent_items, case: support_case, is_read: false) }

        specify "then the case is not longer marked as action required" do
          patch support_email_read_status_path(email, status: "read")
          expect(support_case.reload).not_to be_action_required
        end
      end

      context "when there are no unread emails in the inbox but there are unread sent items" do
        before do
          create(:support_email, :inbox, case: support_case, is_read: true)
          create(:support_email, :sent_items, case: support_case, is_read: false)
        end

        specify "then the case is not longer marked as action required" do
          patch support_email_read_status_path(email, status: "read")
          expect(support_case.reload).not_to be_action_required
        end
      end
    end
  end
end
