require "./spec/support/shared/framework_request_controllers"

describe FrameworkRequests::ConfirmOrganisationsController, type: :controller do
  include_examples "back url", "/procurement-support/search_for_organisation?#{{ framework_support_form: { org_id: '' } }.to_query}"

  shared_examples "school picker" do
    it "redirects to the school picker" do
      params = { framework_support_form: { school_type: "group", org_confirm: "true", org_id: "123" } }
      post(:create, params:)
      expect(response).to redirect_to "/procurement-support/school_picker?#{params.to_query}"
    end
  end

  context "when the user confirms the organisation" do
    before do
      create(:support_establishment_group, uid: "123", establishment_group_type:)
      create(:support_organisation, trust_code: "123")
    end

    context "and the organisation is a federation" do
      let(:establishment_group_type) { create(:support_establishment_group_type, code: 1) }

      before { create(:support_organisation, federation_code: "123") }

      include_examples "school picker"
    end

    context "and the organisation is a trust" do
      let(:establishment_group_type) { create(:support_establishment_group_type, code: 2) }

      include_examples "school picker"
    end

    context "and the organisation is a multi-academy trust" do
      let(:establishment_group_type) { create(:support_establishment_group_type, code: 6) }

      include_examples "school picker"
    end

    context "and the organisation is of a different type" do
      let(:establishment_group_type) { create(:support_establishment_group_type, code: 10) }

      it "redirects to the name page" do
        params = { framework_support_form: { school_type: "group", org_confirm: "true", org_id: "123" } }
        post(:create, params:)
        expect(response).to redirect_to "/procurement-support/name?#{params.to_query}"
      end
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
