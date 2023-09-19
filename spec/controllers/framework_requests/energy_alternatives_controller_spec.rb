require "./spec/support/shared/framework_request_controllers"

describe FrameworkRequests::EnergyAlternativesController, type: :controller do
  include_examples "back url", "/procurement-support/energy_bill"

  describe "on create" do
    context "when the user has selected different format" do
      before { post :create, params: { framework_support_form: { energy_alternative: "different_format" } } }

      it "redirects to the bill uploads page" do
        expect(response).to redirect_to "/procurement-support/bill_uploads"
      end
    end

    context "when the user has selected to email later" do
      before { post :create, params: { framework_support_form: { energy_alternative: "email_later" } } }

      it "redirects to the accessibility needs page" do
        expect(response).to redirect_to "/procurement-support/special_requirements"
      end
    end

    context "when the user has selected no bill" do
      before { post :create, params: { framework_support_form: { energy_alternative: "no_bill" } } }

      it "redirects to the accessibility needs page" do
        expect(response).to redirect_to "/procurement-support/special_requirements"
      end
    end

    context "when the user has selected no thanks" do
      before { post :create, params: { framework_support_form: { energy_alternative: "no_thanks" } } }

      it "redirects to the accessibility needs page" do
        expect(response).to redirect_to "/procurement-support/special_requirements"
      end
    end
  end

  describe "on update" do
    let(:framework_request) { create(:framework_request, category: create(:request_for_help_category, flow: "energy")) }

    context "when the user has selected different format" do
      before { patch :update, params: { id: framework_request.id, framework_support_form: { energy_alternative: "different_format" } } }

      it "redirects to the bill uploads page" do
        expect(response).to redirect_to "/procurement-support/#{framework_request.id}/bill_uploads/edit"
      end
    end

    context "when the user has selected to email later" do
      before { patch :update, params: { id: framework_request.id, framework_support_form: { energy_alternative: "email_later" } } }

      it "redirects to the check-your-answers page" do
        expect(response).to redirect_to "/procurement-support/#{framework_request.id}"
      end
    end

    context "when the user has selected no bill" do
      before { patch :update, params: { id: framework_request.id, framework_support_form: { energy_alternative: "no_bill" } } }

      it "redirects to the check-your-answers page" do
        expect(response).to redirect_to "/procurement-support/#{framework_request.id}"
      end
    end

    context "when the user has selected no thanks" do
      before { patch :update, params: { id: framework_request.id, framework_support_form: { energy_alternative: "no_thanks" } } }

      it "redirects to the check-your-answers page" do
        expect(response).to redirect_to "/procurement-support/#{framework_request.id}"
      end
    end
  end

  describe "on edit" do
    let(:framework_request) { create(:framework_request, category: create(:request_for_help_category, flow: "energy")) }
    let(:params) { { id: framework_request.id } }

    before do
      get :edit, params:
    end

    it "goes back to the energy bill page" do
      expect(controller.view_assigns["back_url"]).to eq "/procurement-support/#{framework_request.id}/energy_bill/edit"
    end
  end
end
