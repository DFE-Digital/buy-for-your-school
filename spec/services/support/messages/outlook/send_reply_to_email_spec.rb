require "rails_helper"

describe Support::Messages::Outlook::SendReplyToEmail do
  subject(:send_reply) do
    described_class.new(
      ms_graph_client: ms_graph_client,
      reply_to_email: reply_to_email,
      reply_text: "<p>My Reply</p>",
      sender: agent,
    )
  end

  let(:agent)                         { Support::AgentPresenter.new(create(:support_agent)) }
  let(:ms_graph_client)               { double("ms_graph_client") }
  let(:reply_to_email)                { create(:support_email, outlook_id: "REPLY-OUTLOOK-ID", case: support_case, subject: "Initial Email") }
  let(:support_case)                  { create(:support_case, ref: "000987", email: "school@contact.com") }

  let(:create_reply_message_repsonse) { double(id: "DRAFT-OUTLOOK-ID", internet_message_id: "IMID1", body: double(content: "Previous content here")) }
  let(:update_message_response)       { double(id: "DRAFT-OUTLOOK-ID", internet_message_id: "IMID1", body: double(content: "My Reply - Previous content here")) }
  let(:send_message_response)         { nil }

  before do
    allow(ms_graph_client).to receive(:create_reply_message).and_return(create_reply_message_repsonse)
    allow(ms_graph_client).to receive(:update_message).and_return(update_message_response)
    allow(ms_graph_client).to receive(:send_message).and_return(send_message_response)

    allow(Support::Messages::Outlook::Synchronisation::Steps::PersistEmail).to receive(:call).and_return(nil)
    allow(Support::Messages::Outlook::Synchronisation::Steps::SurfaceEmailOnCase).to receive(:call).and_return(nil)
  end

  it "creates a draft message in outlook" do
    send_reply.call

    expect(ms_graph_client).to have_received(:create_reply_message)
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

  it "sends the updated the draft reply to the recipient" do
    send_reply.call

    expect(ms_graph_client).to have_received(:send_message)
      .with(
        user_id: SHARED_MAILBOX_USER_ID,
        message_id: "DRAFT-OUTLOOK-ID",
      )
  end

  it "persists the email locally in the database" do
    send_reply.call

    email = Support::Email.find_by(outlook_internet_message_id: "IMID1")
    expect(email.case).to eq(support_case)
    expect(email.replying_to).to eq(reply_to_email)
    expect(email.sender).to eq({ "name" => agent.full_name, "address" => agent.email })

    expect(Support::Messages::Outlook::Synchronisation::Steps::PersistEmail).to have_received(:call)
      .with(anything, email)
    expect(Support::Messages::Outlook::Synchronisation::Steps::SurfaceEmailOnCase).to have_received(:call)
      .with(anything, email)
  end
end
