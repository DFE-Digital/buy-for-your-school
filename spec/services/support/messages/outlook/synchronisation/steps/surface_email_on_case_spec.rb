require "rails_helper"

describe Support::Messages::Outlook::Synchronisation::Steps::SurfaceEmailOnCase do
  let(:support_case) { create(:support_case, action_required: false) }
  let(:email)        { create(:support_email, case: support_case) }
  let(:message)      { double(inbox?: true, sent_date_time: Time.zone.parse("01/01/2022 10:30"), body: double(content: "Email body content")) }

  it "sets the case to action required" do
    described_class.call(message, email)

    expect(support_case.reload.action_required).to be(true)
  end

  it "creates an interaction on the case in order to display it on the messages tab" do
    described_class.call(message, email)

    interaction = support_case.reload.interactions.last

    expect(interaction.body).to eq("Email body content")
    expect(interaction.additional_data["email_id"]).to eq(email.id)
    expect(interaction.created_at).to eq(message.sent_date_time)
  end

  context "when message is coming from the inbox mail folder" do
    it "sets the interaction event type as email_from_school" do
      described_class.call(message, email)

      expect(support_case.reload.interactions.last.event_type).to eq("email_from_school")
    end
  end

  context "when message is coming from sent items folder mail folder" do
    let(:message) { double(inbox?: false, sent_date_time: Time.zone.parse("01/01/2022 10:30"), body: double(content: "Email body content")) }

    it "sets the interaction event type as email_to_school" do
      described_class.call(message, email)

      expect(support_case.reload.interactions.last.event_type).to eq("email_to_school")
    end
  end
end
