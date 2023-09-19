require "./spec/support/shared/framework_request_controllers"

describe FrameworkRequests::DocumentsController, type: :controller do
  include_examples "back url", "/procurement-support/message"

  describe "on create" do
    context "when the document type is none" do
      let(:params) { { framework_support_form: { document_types: %w[none] } } }

      it "redirects to the accessibility needs page" do
        post(:create, params:)
        expect(response).to redirect_to "/procurement-support/special_requirements"
      end
    end

    context "when the document types are anything else" do
      let(:params) { { framework_support_form: { document_types: %w[floor_plans] } } }

      it "redirects to the document upload page" do
        post(:create, params:)
        expect(response).to redirect_to "/procurement-support/document_uploads"
      end
    end
  end

  describe "on update" do
    let(:framework_request) { create(:framework_request, category: create(:request_for_help_category, flow: "services")) }

    context "when the document type is none" do
      before do
        patch :update, params: { id: framework_request.id, framework_support_form: { document_types: %w[none] } }
      end

      it "redirects to the check-your-answers page" do
        expect(response).to redirect_to("/procurement-support/#{framework_request.id}")
      end
    end

    context "when the document types are anything else" do
      before do
        patch :update, params: { id: framework_request.id, framework_support_form: { document_types: %w[floor_plans] } }
      end

      it "redirects to the document uploads page" do
        expect(response).to redirect_to("/procurement-support/#{framework_request.id}/document_uploads/edit")
      end
    end
  end

  describe "on edit" do
    let(:framework_request) { create(:framework_request, category: create(:request_for_help_category, flow: "services")) }
    let(:params) { { id: framework_request.id } }

    context "when the request is for a MAT with multiple schools" do
      before do
        framework_request.update!(school_urns: %w[1 2])
        get :edit, params:
      end

      it "goes back to the same supplier page" do
        expect(controller.view_assigns["back_url"]).to eq "/procurement-support/#{framework_request.id}/same_supplier/edit"
      end
    end

    context "when the request is for a single school" do
      before do
        get :edit, params:
      end

      it "goes back to the contract start date page" do
        expect(controller.view_assigns["back_url"]).to eq "/procurement-support/#{framework_request.id}/contract_start_date/edit"
      end
    end
  end
end
