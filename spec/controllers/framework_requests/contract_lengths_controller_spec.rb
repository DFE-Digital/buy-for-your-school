require "./spec/support/shared/framework_request_controllers"

describe FrameworkRequests::ContractLengthsController, type: :controller do
  include_examples "back url", "/procurement-support/categories"

  describe "on create" do
    it "redirects to the contract start date page" do
      params = { framework_support_form: { contract_length: "not_sure" } }
      post(:create, params:)
      expect(response).to redirect_to "/procurement-support/contract_start_date"
    end
  end

  describe "on edit" do
    let(:framework_request) { create(:framework_request, category: create(:request_for_help_category, flow: "services"), contract_length:, contract_start_date_known:) }

    context "when the flow is unfinished" do
      let(:contract_length) { nil }
      let(:contract_start_date_known) { nil }

      before do
        get :edit, params: { id: framework_request.id }
      end

      it "goes back to the categories page" do
        expect(controller.view_assigns["back_url"]).to eq "/procurement-support/#{framework_request.id}/category/edit"
      end
    end

    context "when the flow is finished" do
      let(:contract_length) { :one_year }
      let(:contract_start_date_known) { false }

      before do
        framework_request.update!(document_types: %w[none])
        get :edit, params: { id: framework_request.id }
      end

      it "goes back to the check-your-answers page" do
        expect(controller.view_assigns["back_url"]).to eq "/procurement-support/#{framework_request.id}"
      end
    end
  end

  describe "on update" do
    let(:framework_request) { create(:framework_request, category: create(:request_for_help_category, flow: "services"), contract_start_date_known:) }

    context "when the flow is unfinished" do
      let(:contract_start_date_known) { nil }

      before do
        patch :update, params: { id: framework_request.id, framework_support_form: { contract_length: "one_year" } }
      end

      it "redirects to the contract start date page" do
        expect(response).to redirect_to("/procurement-support/#{framework_request.id}/contract_start_date/edit")
      end
    end

    context "when the flow is finished" do
      let(:contract_start_date_known) { false }

      before do
        framework_request.update!(document_types: %w[none])
        patch :update, params: { id: framework_request.id, framework_support_form: { contract_length: "one_year" } }
      end

      it "redirects to the check-your-answers page" do
        expect(response).to redirect_to("/procurement-support/#{framework_request.id}")
      end
    end
  end
end
