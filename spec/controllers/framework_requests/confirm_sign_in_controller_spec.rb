describe FrameworkRequests::ConfirmSignInController, type: :controller do
  before { user_is_signed_in(user:) }

  context "when the user belongs to multiple organisations" do
    let(:user) { build(:user, :many_supported_schools) }

    it "redirects to the select organisation page" do
      post :create
      expect(response).to redirect_to "/procurement-support/select_organisation"
    end
  end

  context "when the user belongs to one organisation" do
    let(:user) { build(:user, :one_supported_school) }

    context "when the user has chosen not to upload a bill" do
      let(:framework_request) { create(:framework_request, is_energy_request: false) }

      it "redirects to the message page" do
        post :create, session: { framework_request_id: framework_request.id }
        expect(response).to redirect_to "/procurement-support/message"
      end
    end

    context "when the user has chosen to upload a bill" do
      let(:framework_request) { create(:framework_request, is_energy_request: true, energy_request_about: "energy_contract", have_energy_bill: true) }

      it "redirects to the bill upload page" do
        post :create, session: { framework_request_id: framework_request.id }
        expect(response).to redirect_to "/procurement-support/bill_uploads"
      end
    end
  end
end
