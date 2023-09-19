require "./spec/support/shared/framework_request_controllers"

describe FrameworkRequests::OriginsController, type: :controller do
  let(:framework_request) { create(:framework_request) }

  include_examples "back url", "/procurement-support/special_requirements"

  it "redirects to the framework request page" do
    params = { framework_support_form: { origin: "website" } }
    session = { framework_request_id: framework_request.id }
    post(:create, params:, session:)
    expect(response).to redirect_to "/procurement-support/#{framework_request.id}"
  end
end
