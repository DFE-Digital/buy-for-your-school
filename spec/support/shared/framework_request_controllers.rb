shared_examples "sign-in redirects" do |post_params|
  context "when the user is not signed in" do
    before { post :create, params: post_params }

    it "redirects to the sign in page" do
      expect(response).to redirect_to(/\/procurement-support\/sign_in\?back_to=/)
    end
  end

  context "when the user is signed in" do
    before do
      user_is_signed_in
      post :create, params: post_params
    end

    it "redirects to the confirm sign in page" do
      expect(response).to redirect_to "/procurement-support/confirm_sign_in"
    end
  end
end

shared_examples "back url" do |url|
  it "goes back to the right page" do
    get :index
    expect(controller.view_assigns["back_url"]).to eq url
  end
end
