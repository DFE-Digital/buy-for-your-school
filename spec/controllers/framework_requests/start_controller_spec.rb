describe FrameworkRequests::StartController, type: :controller do
  it "redirects to the energy request page" do
    post :create
    expect(response).to redirect_to "/procurement-support/energy_request"
  end

  context "when feature :energy_bill_flow is not enabled" do
    before { Flipper.disable(:energy_bill_flow) }

    context "when user is a guest" do
      it "redirects to dfe sign in" do
        post :create
        expect(response).to redirect_to "/procurement-support/sign_in"
      end
    end

    context "when user is signed in" do
      before { user_is_signed_in }

      it "confirms the user sign in" do
        post :create
        expect(response).to redirect_to "/procurement-support/confirm_sign_in"
      end
    end
  end
end
