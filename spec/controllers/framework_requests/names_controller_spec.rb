require "./spec/support/shared/framework_request_controllers"

describe FrameworkRequests::NamesController, type: :controller do
  include_examples "back url", "/procurement-support/confirm_organisation"

  it "redirects to the email page" do
    params = { framework_support_form: { first_name: "first", last_name: "last" } }
    post :create, params: params
    expect(response).to redirect_to "/procurement-support/email"
  end
end
