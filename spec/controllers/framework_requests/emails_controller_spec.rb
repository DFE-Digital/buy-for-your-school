require "./spec/support/shared/framework_request_controllers"

describe FrameworkRequests::EmailsController, type: :controller do
  include_examples "back url", "/procurement-support/name"

  it "redirects to the categories page" do
    post :create, params: { framework_support_form: { email: "test@example.com" } }
    expect(response).to redirect_to "/procurement-support/categories"
  end
end
