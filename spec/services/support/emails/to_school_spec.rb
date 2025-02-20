require "rails_helper"

describe Support::Emails::ToSchool do
  subject(:service) { described_class }

  let(:support_case) { create(:support_case) }

  let(:parameters) do
    {
      recipient: support_case,
      template: "any",
      client: double(send_email: nil),
    }
  end

  describe "#call" do
    context "when recipient case has only one email interaction" do
      before do
        support_case.interactions.email_to_school.create!(
          body: "test email body",
        )
      end

      it "records the action 'first_contact'" do
        record_action = instance_double("Support::RecordAction", call: nil)
        allow(Support::RecordAction).to receive(:new)
          .with(case_id: support_case.id, action: "first_contact")
          .and_return(record_action)

        service.new(**parameters).call

        expect(record_action).to have_received(:call).once
      end
    end

    context "when recipient case has more than one email interaction already" do
      before do
        2.times do
          support_case.interactions.email_to_school.create!(
            body: "test email body",
          )
        end
      end

      it "does not record the action 'first_contact'" do
        record_action = instance_double("Support::RecordAction", call: nil)
        allow(Support::RecordAction).to receive(:new)
          .with(case_id: support_case.id, action: "first_contact")
          .and_return(record_action)

        service.new(**parameters).call

        expect(record_action).not_to have_received(:call)
      end
    end
  end
end
