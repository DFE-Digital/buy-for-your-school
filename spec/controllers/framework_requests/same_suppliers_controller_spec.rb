require "./spec/support/shared/framework_request_controllers"

describe FrameworkRequests::SameSuppliersController, type: :controller do
  include_examples "back url", "/procurement-support/contract_start_date"

  describe "on create" do
    it "redirects to the procurement amount page" do
      params = { framework_support_form: { same_supplier_used: "yes" } }
      post(:create, params:)
      expect(response).to redirect_to "/procurement-support/procurement_amount"
    end
  end

  describe "on edit" do
    let(:framework_request) { create(:framework_request, category: create(:request_for_help_category, flow: "services"), contract_length: :one_year, contract_start_date_known: false) }

    context "when coming in from the check-your-answers page" do
      let(:framework_support_form) { { framework_support_form: { source: "change_link" } } }
      let(:params) { { id: framework_request.id, **framework_support_form } }

      before { get :edit, params: }

      it "goes back to the check-your-answers page" do
        expect(controller.view_assigns["back_url"]).to eq "/procurement-support/#{framework_request.id}"
      end
    end

    context "when the flow is unfinished" do
      let(:params) { { id: framework_request.id } }

      before { get :edit, params: }

      it "goes back to the contract start date page" do
        expect(controller.view_assigns["back_url"]).to eq "/procurement-support/#{framework_request.id}/contract_start_date/edit"
      end
    end

    context "when the flow is finished" do
      let(:params) { { id: framework_request.id } }

      before do
        framework_request.update!(document_types: %w[none])
        get :edit, params:
      end

      it "goes back to the confirm schools page" do
        expect(controller.view_assigns["back_url"]).to eq "/procurement-support/#{framework_request.id}/confirm_schools/edit"
      end
    end
  end

  describe "on update" do
    let(:framework_request) { create(:framework_request, contract_length: :one_year, contract_start_date_known: false, category:) }
    let(:category) { create(:request_for_help_category, flow: "services") }

    context "when the flow is unfinished" do
      context "and the user has chosen gas or electricity" do
        let(:category) { create(:request_for_help_category, slug: "electricity", flow: "energy") }

        before do
          patch :update, params: { id: framework_request.id, framework_support_form: { same_supplier_used: "yes" } }
        end

        it "redirects to the energy bill page" do
          expect(response).to redirect_to("/procurement-support/#{framework_request.id}/energy_bill/edit")
        end
      end

      context "and the user has chosen a service or a different energy category" do
        before do
          patch :update, params: { id: framework_request.id, framework_support_form: { same_supplier_used: "yes" } }
        end

        it "redirects to the documents page" do
          expect(response).to redirect_to("/procurement-support/#{framework_request.id}/documents/edit")
        end
      end
    end

    context "when the flow is finished" do
      let(:contract_start_date) { Date.parse("2023-09-21") }

      before do
        framework_request.update!(document_types: %w[none])
        patch :update, params: { id: framework_request.id, framework_support_form: { same_supplier_used: "yes" } }
      end

      it "redirects to the check-your-answers page" do
        expect(response).to redirect_to("/procurement-support/#{framework_request.id}")
      end
    end
  end
end
