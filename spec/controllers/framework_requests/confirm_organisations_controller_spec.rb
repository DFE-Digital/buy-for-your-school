require "./spec/support/shared/framework_request_controllers"

describe FrameworkRequests::ConfirmOrganisationsController, type: :controller do
  include_examples "back url", "/procurement-support/search_for_organisation?#{{ framework_support_form: { org_id: '' } }.to_query}"

  context "when the user confirms the organisation" do
    it "redirects to the name page" do
      params = { framework_support_form: { org_confirm: "true", org_id: "" } }
      post(:create, params:)
      expect(response).to redirect_to "/procurement-support/name?#{params.to_query}"
    end
  end

  context "when the user does not confirm the organisation" do
    it "redirects to the search for organisation page" do
      params = { framework_support_form: { org_confirm: "false", org_id: "" } }
      post(:create, params:)
      expect(response).to redirect_to "/procurement-support/search_for_organisation?#{{ framework_support_form: { org_id: '' } }.to_query}"
    end
  end
end
