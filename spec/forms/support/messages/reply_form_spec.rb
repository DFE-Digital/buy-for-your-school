require "rails_helper"

describe Support::Messages::ReplyForm do
  describe "sending the reply" do
    let(:email) { build(:support_email) }
    let(:agent) { Support::AgentPresenter.new(build(:support_agent)) }
    let(:body) { "<p>Well hello</p>" }

    it "delegates to SendReplyToEmail with the correct template" do
      reply = double(call: nil)
      allow(Support::Messages::Outlook::SendReplyToEmail).to receive(:new).and_return(reply)

      email_body = Support::Messages::Templates.new(params: { body: body, agent: agent.full_name }).call

      described_class.new(body: body).reply_to_email(email, agent)

      expect(Support::Messages::Outlook::SendReplyToEmail).to have_received(:new).with(
        reply_to_email: email,
        reply_text: email_body,
        sender: agent,
      )
      expect(reply).to have_received(:call).once
    end
  end
end
