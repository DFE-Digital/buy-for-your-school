require "rails_helper"

describe Support::Case::EmailTicketable do
  describe "on attaching email to case" do
    context "when email already has a ticket assigned (just sent as a draft message)" do
      it "remains attached to that ticket" do
        support_case = create(:support_case, :initial)
        email = create(:support_email, ticket: support_case)

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
  end
end
