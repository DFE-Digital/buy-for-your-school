require "rails_helper"

describe Support::Messages::Outlook::SendNewMessage do
  subject(:send_message) do
    described_class.new(
      ms_graph_client:,
      to_recipients: ["test@test.com"],
      cc_recipients: ["cc@test.com"],
      bcc_recipients: ["bcc@test.com"],
      subject: "subject",
      message_text: "<p>Message</p>",
      sender: agent,
      file_attachments: [attachment1, attachment2],
      template_id:,
    )
  end

  let(:agent)                         { Support::AgentPresenter.new(create(:support_agent)) }
  let(:ms_graph_client)               { double("ms_graph_client") }
  let(:support_case)                  { create(:support_case, ref: "000987", email: "school@contact.com") }
  let(:attachment1)                   { double("attachment1") }
  let(:attachment2)                   { double("attachment2") }
  let(:template_id)                   { "template-1" }

  let(:create_message_response)       { "DRAFT-OUTLOOK-ID" }
  let(:update_message_response)       { double("update_message_response", id: "DRAFT-OUTLOOK-ID", internet_message_id: "IMID1", body: double(content: "<p>Message</p>")) }
  let(:send_message_response)         { nil }
  let(:get_message_response)          { double("get_message_response", id: "DRAFT-OUTLOOK-ID", internet_message_id: "IMID1", body: double(content: "<p>Message</p>")) }

  before do
    allow(ms_graph_client).to receive(:create_message).and_return(create_message_response)
    allow(ms_graph_client).to receive(:update_message).and_return(update_message_response)
    allow(ms_graph_client).to receive(:send_message).and_return(send_message_response)
    allow(ms_graph_client).to receive(:get_message).and_return(get_message_response)
    allow(ms_graph_client).to receive(:add_file_attachment_to_message)

    allow(Support::Messages::Outlook::SynchroniseMessage).to receive(:call).and_return(nil)
  end

  it "creates a draft message in outlook" do
    send_message.call

    expect(ms_graph_client).to have_received(:create_message)
      .with(
        user_id: SHARED_MAILBOX_USER_ID,
        http_headers: { "Prefer" => 'IdType="ImmutableId"' },
      )
  end

  it "updates the draft message to have the intended message text body" do
    send_message.call

    expect(ms_graph_client).to have_received(:update_message)
      .with(
        user_id: SHARED_MAILBOX_USER_ID,
        message_id: "DRAFT-OUTLOOK-ID",
        details: {
          body: {
            "ContentType" => "HTML",
            "content" => "<p>Message</p>",
          },
          from: {
            emailAddress: {
              "address" => "test@mailbox.com",
              "name" => "mailbox",
            },
          },
          subject: "subject",
          toRecipients: [
            {
              "emailAddress" => {
                "address" => "test@test.com",
              },
            },
          ],
          ccRecipients: [
            {
              "emailAddress" => {
                "address" => "cc@test.com",
              },
            },
          ],
          bccRecipients: [
            {
              "emailAddress" => {
                "address" => "bcc@test.com",
              },
            },
          ],
        },
      )
  end

  it "updates the message with attachments" do
    send_message.call

    expect(ms_graph_client).to have_received(:add_file_attachment_to_message)
      .with(
        user_id: SHARED_MAILBOX_USER_ID,
        message_id: "DRAFT-OUTLOOK-ID",
        file_attachment: attachment1,
      )
    expect(ms_graph_client).to have_received(:add_file_attachment_to_message)
      .with(
        user_id: SHARED_MAILBOX_USER_ID,
        message_id: "DRAFT-OUTLOOK-ID",
        file_attachment: attachment2,
      )
  end

  it "sends the updated the draft message to the recipient" do
    send_message.call

    expect(ms_graph_client).to have_received(:send_message)
      .with(
        user_id: SHARED_MAILBOX_USER_ID,
        message_id: "DRAFT-OUTLOOK-ID",
      )
  end

  it "synchronises the message" do
    send_message.call

    expect(Support::Messages::Outlook::SynchroniseMessage).to have_received(:call)
      .with(Support::Messages::Outlook::Message.new(get_message_response), { template_id: })
  end
end
