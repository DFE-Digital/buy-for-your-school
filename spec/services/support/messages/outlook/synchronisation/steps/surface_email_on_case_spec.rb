require "rails_helper"

describe Support::Messages::Outlook::Synchronisation::Steps::SurfaceEmailOnCase do
  let(:support_case) { create(:support_case, action_required: false) }
  let(:email)        { create(:support_email, case: support_case) }
  let(:message)      { double(inbox?: true, sent_date_time: Time.zone.parse("01/01/2022 10:30"), body: double(content: "Email body content")) }

  it "sets the case to action required" do
    described_class.call(message, email)

    expect(support_case.reload.action_required).to be(true)
  end

  it "creates a single email_from_school interaction on the case" do
    expect { described_class.call(message, email) }.to change { support_case.reload.interactions.email_from_school.count }.from(0).to(1)
    expect { described_class.call(message, email) }.not_to change { support_case.reload.interactions.email_from_school.count }.from(1)

    expect(support_case.reload.interactions.email_from_school.last.created_at).to be_within(1.second).of(Time.zone.now)
  end

  context "when message is coming from sent items folder mail folder" do
    let(:message) { double(inbox?: false, sent_date_time: Time.zone.parse("01/01/2022 10:30"), body: double(content: "Email body content")) }

    it "does not set the case to action required" do
      described_class.call(message, email)

      expect(support_case.reload.action_required).not_to be(true)
    end

    it "creates a single email_to_school interaction on the case" do
      expect { described_class.call(message, email) }.to change { support_case.reload.interactions.email_to_school.count }.from(0).to(1)
      expect { described_class.call(message, email) }.not_to change { support_case.reload.interactions.email_to_school.count }.from(1)

      expect(support_case.reload.interactions.email_to_school.last.created_at).to be_within(1.second).of(Time.zone.now)
    end
  end
end
