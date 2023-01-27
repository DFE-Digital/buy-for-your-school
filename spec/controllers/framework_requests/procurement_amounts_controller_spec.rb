require "./spec/support/shared/framework_request_controllers"

describe FrameworkRequests::ProcurementAmountsController, type: :controller do
  include_examples "back url", "/procurement-support/message"

  it "redirects to the special requirements page" do
    post :create
    expect(response).to redirect_to "/procurement-support/special_requirements"
  end
end
