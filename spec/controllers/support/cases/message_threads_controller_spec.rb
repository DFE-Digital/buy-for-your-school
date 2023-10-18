describe Support::Cases::MessageThreadsController, type: :controller do
  describe "show" do
    let(:email) { create(:support_email) }

    before { agent_is_signed_in }

    context "when the request is not from a turbo frame" do
      it "redirects to the case with a message tab URL" do
        get :show, params: { id: email.outlook_conversation_id, case_id: email.ticket_id }

        expect(response).to redirect_to "/support/cases/#{email.ticket_id}?messages_tab_url=#{CGI.escape(request.url)}#messages"
      end
    end

    context "when the request is from a turbo frame" do
      before { request.headers["Turbo-Frame"] = "1" }

      context "when a URL for the reply frame is provided" do
        let(:case_id) { email.ticket_id }
        let(:message_id) { email.id }
        let(:template_id) { "template-1" }
        let(:reply_frame_url) { new_support_case_message_reply_path(case_id:, message_id: email.id) }
        let(:params) { { id: email.outlook_conversation_id, case_id:, reply_frame_url:, template_id: } }

        before { get(:show, params:) }

        it "sets the reply_frame_url with the template ID attached" do
          expect(controller.view_assigns["reply_frame_url"]).to eq("/support/cases/#{case_id}/messages/#{message_id}/replies/new?template_id=#{template_id}")
        end
      end
    end
  end
end
