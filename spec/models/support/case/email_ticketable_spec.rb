require "rails_helper"

describe Support::Case::EmailTicketable do
  describe "on attaching email to case" do
    context "when email already has a ticket assigned (just sent as a draft message)" do
      it "remains attached to that ticket" do
        support_case = create(:support_case, :initial)
        email = create(:email, ticket: support_case)

        Support::Case.on_email_cached(email)

        expect(email.reload.ticket).to eq(support_case)
      end
    end

    context "when the email is sent" do
      context "and case is 'New' state" do
        it "moves the case to 'on_hold'" do
          support_case = create(:support_case, :initial)
          support_case.emails << Email.new(folder: :sent_items)

          expect(support_case.reload.state).to eq("on_hold")
        end
      end
    end

    context "when the email was received today" do
      it "creates a notification for the caseworker" do
        support_case = create(:support_case, :initial)
        email = Email.new(
          folder: :inbox,
          outlook_conversation_id: "123",
          sender: { name: "Test User", address: "test@email.com" },
          outlook_received_at: Time.zone.now,
        )
        support_case.emails << email

        expect(Support::Notification.case_email_recieved.where(
          support_case:,
          assigned_to: support_case.agent,
          subject: email,
          assigned_by_system: true,
          created_at: email.outlook_received_at,
        ).count).to eq(1)
      end
    end
  end
end
