describe FrameworkRequests::StartController, type: :controller do
  it "redirects to the energy request page" do
    post :create
    expect(response).to redirect_to "/procurement-support/energy_request"
  end
end
