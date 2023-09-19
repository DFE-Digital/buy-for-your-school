describe FrameworkRequests::StartController, type: :controller do
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
