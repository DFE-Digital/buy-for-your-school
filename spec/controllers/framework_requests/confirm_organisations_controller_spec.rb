require "./spec/support/shared/framework_request_controllers"

describe FrameworkRequests::ConfirmOrganisationsController, type: :controller do
  let(:organisation) { create(:support_organisation) }
  let(:organisation_id) { organisation.id }
  let(:organisation_type) { organisation.class.name }

  include_examples "back url", "/procurement-support/search_for_organisation?#{{ framework_support_form: { organisation_id: '', organisation_type: '' } }.to_query}"

  context "when the user confirms the organisation" do
    it "redirects to the name page" do
      params = { framework_support_form: { org_confirm: "true", organisation_id:, organisation_type: } }
      post(:create, params:)
      expect(response).to redirect_to "/procurement-support/name?#{params.to_query}"
    end
  end

  context "when the user does not confirm the organisation" do
    it "redirects to the search for organisation page" do
      params = { framework_support_form: { org_confirm: "false", organisation_id:, organisation_type: } }
      post(:create, params:)
      expect(response).to redirect_to "/procurement-support/search_for_organisation"
    end
  end
end
