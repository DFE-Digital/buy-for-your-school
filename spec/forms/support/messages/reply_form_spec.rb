require "rails_helper"

describe Support::Messages::ReplyForm do
  let(:agent) { Support::AgentPresenter.new(build(:support_agent)) }
  let(:body) { "<p>Well hello</p>" }

  describe "sending the reply" do
    let(:email) { build(:support_email) }

    let(:attachment1) { fixture_file_upload Rails.root.join("spec/fixtures/gias/example_schools_data.csv"), "text/csv" }
    let(:attachment2) { fixture_file_upload Rails.root.join("spec/fixtures/gias/example_establishment_groups_data.csv"), "text/csv" }

    it "delegates to SendReplyToEmail" do
      reply = double(call: nil)
      allow(Support::Messages::Outlook::SendReplyToEmail).to receive(:new).and_return(reply)

      file_attachment1 = double("file_attachment1")
      file_attachment2 = double("file_attachment2")
      allow(Support::Messages::Outlook::Reply::FileAttachment).to receive(:from_uploaded_file).with(attachment1).and_return(file_attachment1)
      allow(Support::Messages::Outlook::Reply::FileAttachment).to receive(:from_uploaded_file).with(attachment2).and_return(file_attachment2)

      described_class.new(body:, attachments: [attachment1, attachment2]).reply_to_email(email, agent)

      expect(Support::Messages::Outlook::SendReplyToEmail).to have_received(:new).with(
        reply_to_email: email,
        reply_text: body,
        sender: agent,
        file_attachments: [file_attachment1, file_attachment2],
      )
      expect(reply).to have_received(:call).once
    end
  end

  describe "#create_new_message" do
    let(:to_recipients) { "[\"recipient1\"]" }
    let(:cc_recipients) { "[\"recipient2\"]" }
    let(:bcc_recipients) { "[\"recipient3\"]" }
    let(:message_subject) { "subject" }

    it "delegates to SendNewMessage" do
      message = double(call: nil)
      allow(Support::Messages::Outlook::SendNewMessage).to receive(:new).and_return(message)

      described_class.new(
        body:,
        to_recipients:,
        cc_recipients:,
        bcc_recipients:,
        subject: message_subject,
      ).create_new_message(agent)

      expect(Support::Messages::Outlook::SendNewMessage).to have_received(:new).with(
        to_recipients: JSON.parse(to_recipients),
        cc_recipients: JSON.parse(cc_recipients),
        bcc_recipients: JSON.parse(bcc_recipients),
        message_text: body,
        sender: agent,
        file_attachments: [],
        subject: message_subject,
      )

      expect(message).to have_received(:call).once
    end
  end
end
