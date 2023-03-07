describe Support::Cases::MessageThreadsController, type: :controller do
  describe "show" do
    let(:email) { create(:support_email) }

    before { agent_is_signed_in }

    context "when the request is not from a turbo frame" do
      it "redirects to the case with a message tab URL" do
        get :show, params: { id: email.outlook_conversation_id, case_id: email.case.id }

        expect(response).to redirect_to "/support/cases/#{email.case.id}?messages_tab_url=#{CGI.escape(request.url)}#messages"
      end
    end
  end
end
