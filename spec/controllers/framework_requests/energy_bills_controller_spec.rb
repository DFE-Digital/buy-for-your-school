require "./spec/support/shared/framework_request_controllers"

describe FrameworkRequests::EnergyBillsController, type: :controller do
  include_examples "back url", "/procurement-support/message"

  describe "on create" do
    context "when the user has no bill" do
      before { post :create, params: { framework_support_form: { have_energy_bill: "false" } } }

      it "redirects to the energy alternative page" do
        expect(response).to redirect_to "/procurement-support/energy_alternative"
      end
    end

    context "when the user has a bill" do
      before { post :create, params: { framework_support_form: { have_energy_bill: "true" } } }

      it "redirects to the bill uploads page" do
        expect(response).to redirect_to "/procurement-support/bill_uploads"
      end
    end
  end

  describe "on update" do
    let(:framework_request) { create(:framework_request, category: create(:request_for_help_category, flow: "energy")) }

    context "when the user has an energy bill" do
      before do
        patch :update, params: { id: framework_request.id, framework_support_form: { have_energy_bill: "true" } }
      end

      it "redirects to the bill uploads page" do
        expect(response).to redirect_to("/procurement-support/#{framework_request.id}/bill_uploads/edit")
      end
    end

    context "when the user does not have an energy bill" do
      before do
        patch :update, params: { id: framework_request.id, framework_support_form: { have_energy_bill: "false" } }
      end

      it "redirects to the energy alternative page" do
        expect(response).to redirect_to("/procurement-support/#{framework_request.id}/energy_alternative/edit")
      end
    end
  end

  describe "on edit" do
    let(:framework_request) { create(:framework_request, category: create(:request_for_help_category, flow: "energy")) }
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
