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
        before { create(:support_email, :inbox, ticket: support_case, is_read: false) }

        specify "then the case remains as action required" do
          patch support_email_read_status_path(email, status: "read")
          expect(support_case.reload).to be_action_required
        end
      end

      context "when there are other unread emails in the sent items folder" do
        before { create(:support_email, :sent_items, ticket: support_case, is_read: false) }

        specify "then the case is not longer marked as action required" do
          patch support_email_read_status_path(email, status: "read")
          expect(support_case.reload).not_to be_action_required
        end
      end

      context "when there are no unread emails in the inbox but there are unread sent items" do
        before do
          create(:support_email, :inbox, ticket: support_case, is_read: true)
          create(:support_email, :sent_items, ticket: support_case, is_read: false)
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

      context "when there are other unread emails in the inbox and no evaluations for review" do
        before do
          create(:support_email, :inbox, ticket: support_case, is_read: false)
          support_case.evaluators.create!(first_name: "Momo", last_name: "Taro", email: "email@address", has_uploaded_documents: false, evaluation_approved: false)
        end

        specify "then the case remains as action required" do
          patch support_email_read_status_path(email, status: "read")
          expect(support_case.reload).to be_action_required
        end
      end

      context "when there are other unread emails in the Sent Items folder and no evaluations for review" do
        before do
          create(:support_email, :sent_items, ticket: support_case, is_read: false)
          support_case.evaluators.create!(first_name: "Momo", last_name: "Taro", email: "email@address", has_uploaded_documents: false, evaluation_approved: false)
        end

        specify "then the case is not longer marked as action required" do
          patch support_email_read_status_path(email, status: "read")
          expect(support_case.reload).not_to be_action_required
        end
      end

      context "when there are no unread emails in the inbox, unread sent items, and no evaluations pending for review" do
        before do
          create(:support_email, :inbox, ticket: support_case, is_read: true)
          create(:support_email, :sent_items, ticket: support_case, is_read: false)
          support_case.evaluators.create!(first_name: "Momo", last_name: "Taro", email: "email@address", has_uploaded_documents: false, evaluation_approved: false)
        end

        specify "then the case is not longer marked as action required" do
          patch support_email_read_status_path(email, status: "read")
          expect(support_case.reload).not_to be_action_required
        end
      end

      context "when there are no unread emails in the inbox and there are evaluations for review" do
        before do
          create(:support_email, :inbox, ticket: support_case, is_read: true)
          support_case.evaluators.create!(first_name: "Momo", last_name: "Taro", email: "email@address", has_uploaded_documents: true, evaluation_approved: false)
        end

        specify "then the case is marked as action required" do
          patch support_email_read_status_path(email, status: "read")
          expect(support_case.reload).to be_action_required
        end
      end

      context "when there are no unread emails in the inbox and no evaluations for review" do
        before do
          create(:support_email, :inbox, ticket: support_case, is_read: true)
          support_case.evaluators.create!(first_name: "Momo", last_name: "Taro", email: "email@address", has_uploaded_documents: true, evaluation_approved: true)
        end

        specify "then the case is not longer marked as action required" do
          patch support_email_read_status_path(email, status: "read")
          expect(support_case.reload).not_to be_action_required
        end
      end
    end
  end
end
