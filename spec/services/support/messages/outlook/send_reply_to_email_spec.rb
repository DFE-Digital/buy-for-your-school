require "rails_helper"

describe Support::Messages::Outlook::SendReplyToEmail do
  subject(:send_reply) do
    described_class.new(
      ms_graph_client:,
      reply_to_email:,
      reply_text: "<p>My Reply</p>",
      sender: agent,
      file_attachments: [attachment1, attachment2],
      template_id:,
    )
  end

  let(:agent)                         { Support::AgentPresenter.new(create(:support_agent)) }
  let(:ms_graph_client)               { double("ms_graph_client") }
  let(:reply_to_email)                { create(:support_email, outlook_id: "REPLY-OUTLOOK-ID", case: support_case, subject: "Initial Email") }
  let(:support_case)                  { create(:support_case, ref: "000987", email: "school@contact.com") }
  let(:attachment1)                   { double("attachment1") }
  let(:attachment2)                   { double("attachment2") }
  let(:template_id)                   { "template-1" }

  let(:create_reply_all_message_repsonse) { double("create_reply_all_message_repsonse", id: "DRAFT-OUTLOOK-ID", internet_message_id: "IMID1", body: double(content: "Previous content here")) }
  let(:update_message_response)       { double("update_message_response", id: "DRAFT-OUTLOOK-ID", internet_message_id: "IMID1", body: double(content: "My Reply - Previous content here")) }
  let(:send_message_response)         { nil }
  let(:get_message_response)          { double("get_message_response", id: "DRAFT-OUTLOOK-ID", internet_message_id: "IMID1", body: double(content: "My Reply - Previous content here")) }

  before do
    allow(ms_graph_client).to receive(:create_reply_all_message).and_return(create_reply_all_message_repsonse)
    allow(ms_graph_client).to receive(:update_message).and_return(update_message_response)
    allow(ms_graph_client).to receive(:send_message).and_return(send_message_response)
    allow(ms_graph_client).to receive(:get_message).and_return(get_message_response)
    allow(ms_graph_client).to receive(:add_file_attachment_to_message)

    allow(Support::Messages::Outlook::SynchroniseMessage).to receive(:call).and_return(nil)
  end

  it "creates a draft message in outlook" do
    send_reply.call

    expect(ms_graph_client).to have_received(:create_reply_all_message)
      .with(
        user_id: SHARED_MAILBOX_USER_ID,
        reply_to_id: "REPLY-OUTLOOK-ID",
        http_headers: { "Prefer" => 'IdType="ImmutableId"' },
      )
  end

  it "updates the draft reply to have the intended reply text body" do
    send_reply.call

    expect(ms_graph_client).to have_received(:update_message)
      .with(
        user_id: SHARED_MAILBOX_USER_ID,
        message_id: "DRAFT-OUTLOOK-ID",
        details: {
          body: {
            "ContentType" => "HTML",
            "content" => "<html><body><p>My Reply</p></body></html>Previous content here",
          },
        },
      )
  end

  it "updates the message with attachments" do
    send_reply.call

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

  it "sends the updated the draft reply to the recipient" do
    send_reply.call

    expect(ms_graph_client).to have_received(:send_message)
      .with(
        user_id: SHARED_MAILBOX_USER_ID,
        message_id: "DRAFT-OUTLOOK-ID",
      )
  end

  it "synchronises the message" do
    send_reply.call

    expect(Support::Messages::Outlook::SynchroniseMessage).to have_received(:call)
      .with(Support::Messages::Outlook::Message.new(get_message_response), { template_id: })
  end
end
