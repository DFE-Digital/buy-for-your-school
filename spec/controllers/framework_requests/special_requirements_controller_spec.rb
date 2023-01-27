require "./spec/support/shared/framework_request_controllers"

describe FrameworkRequests::SpecialRequirementsController, type: :controller do
  include_examples "back url", "/procurement-support/procurement_amount"

  it "redirects to the framework request page" do
    params = { framework_support_form: { special_requirements_choice: "no" } }
    post(:create, params:)
    expect(response).to redirect_to "/procurement-support/#{FrameworkRequest.first.id}"
  end
end
