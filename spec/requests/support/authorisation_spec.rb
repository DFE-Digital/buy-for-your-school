RSpec.describe "Authentication", type: :request do
  context "when DSI user signed in but no agent" do
    before do
      user_is_signed_in
    end

    describe "accessing case management" do
      # support_cases_path
      it "redirects to support login" do
        get support_cases_path
        expect(response).to redirect_to "/support"
      end
    end
  end

  context "when agent signed in" do
    before do
      agent_is_signed_in
    end

    describe "accessing case management" do
      # support_cases_path
      it "allows access to case management" do
        get support_cases_path
        expect(response).to have_http_status(:ok)
        expect(response.body).to include("No cases found")
      end
    end
  end
end
