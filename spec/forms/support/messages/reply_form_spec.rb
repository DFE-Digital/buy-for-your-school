require "rails_helper"

describe Support::Messages::ReplyForm do
  describe "sending the reply" do
    let(:email) { build(:support_email) }
    let(:agent) { Support::AgentPresenter.new(build(:support_agent)) }
    let(:body) { "<p>Well hello</p>" }

    let(:attachment1) { fixture_file_upload Rails.root.join("spec/fixtures/gias/example_schools_data.csv"), "text/csv" }
    let(:attachment2) { fixture_file_upload Rails.root.join("spec/fixtures/gias/example_establishment_groups_data.csv"), "text/csv" }

    it "delegates to SendReplyToEmail with the correct template" do
      reply = double(call: nil)
      allow(Support::Messages::Outlook::SendReplyToEmail).to receive(:new).and_return(reply)

      file_attachment1 = double("file_attachment1")
      file_attachment2 = double("file_attachment2")
      allow(Support::Messages::Outlook::Reply::FileAttachment).to receive(:from_uploaded_file).with(attachment1).and_return(file_attachment1)
      allow(Support::Messages::Outlook::Reply::FileAttachment).to receive(:from_uploaded_file).with(attachment2).and_return(file_attachment2)

      email_body = Support::Messages::Templates.new(params: { body: body, agent: agent.full_name }).call

      described_class.new(body: body, attachments: [attachment1, attachment2]).reply_to_email(email, agent)

      expect(Support::Messages::Outlook::SendReplyToEmail).to have_received(:new).with(
        reply_to_email: email,
        reply_text: email_body,
        sender: agent,
        file_attachments: [file_attachment1, file_attachment2],
      )
      expect(reply).to have_received(:call).once
    end
  end
end
