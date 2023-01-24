require "./spec/support/shared/framework_request_controllers"

describe FrameworkRequests::OrganisationTypesController, type: :controller do
  include_examples "back url", "/procurement-support/sign_in"

  it "redirects to the search for organisation page" do
    params = { framework_support_form: { school_type: "school" } }
    post :create, params: params
    expect(response).to redirect_to "/procurement-support/search_for_organisation?#{params.to_query}"
  end
end
