require "rails_helper"

describe Support::Messages::Outlook::Synchronisation::Steps::SurfaceEmailOnCase do
  let(:support_case) { create(:support_case, action_required: false) }
  let(:email)        { create(:support_email, case: support_case) }
  let(:message)      { double(inbox?: true, sent_date_time: Time.zone.parse("01/01/2022 10:30"), body: double(content: "Email body content")) }

  it "sets the case to action required" do
    described_class.call(message, email)

    expect(support_case.reload.action_required).to be(true)
  end

  context "when message is coming from sent items folder mail folder" do
    let(:message) { double(inbox?: false, sent_date_time: Time.zone.parse("01/01/2022 10:30"), body: double(content: "Email body content")) }

    it "does not set the case to action required" do
      described_class.call(message, email)

      expect(support_case.reload.action_required).not_to be(true)
    end
  end
end
