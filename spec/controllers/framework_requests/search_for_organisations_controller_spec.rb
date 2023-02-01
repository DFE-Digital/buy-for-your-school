require "./spec/support/shared/framework_request_controllers"

describe FrameworkRequests::SearchForOrganisationsController, type: :controller do
  include_examples "back url", "/procurement-support/organisation_type?#{{ framework_support_form: { school_type: 'school' } }.to_query}"

  it "redirects to the confirm organisation page" do
    org = create(:support_organisation)
    params = { framework_support_form: { org_id: org.formatted_name, school_type: "school" } }
    post(:create, params:)
    expect(response).to redirect_to "/procurement-support/confirm_organisation?#{params.to_query}"
  end
end
