require "./spec/support/shared/framework_request_controllers"

describe FrameworkRequests::SelectOrganisationsController, type: :controller do
  before do
    user_is_signed_in
  end

  include_examples "back url", "/procurement-support/confirm_sign_in"

  context "when the user has chosen a MAT or federation" do
    let(:framework_request) { create(:framework_request) }

    before do
      create(:support_establishment_group, uid: "123", establishment_group_type: create(:support_establishment_group_type, code: 2))
      create(:support_organisation, trust_code: "123")
    end

    it "redirects to the school picker" do
      post :create, params: { framework_support_form: { group: "true", org_id: "123" } }, session: { framework_request_id: framework_request.id }
      expect(response).to redirect_to "/procurement-support/school_picker"
    end
  end

  context "when the user has chosen a single school" do
    let(:framework_request) { create(:framework_request) }

    before do
      create(:support_organisation, urn: "123")
    end

    it "redirects to the categories page" do
      post :create, params: { framework_support_form: { group: "false", org_id: "123" } }, session: { framework_request_id: framework_request.id }
      expect(response).to redirect_to "/procurement-support/categories"
    end
  end
end
