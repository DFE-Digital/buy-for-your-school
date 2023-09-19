require "./spec/support/shared/framework_request_controllers"

describe FrameworkRequests::BillUploadsController, type: :controller do
  describe "on create" do
    it "redirects to the accessibility needs page" do
      post :create
      expect(response).to redirect_to "/procurement-support/special_requirements"
    end

    describe "back url" do
      include_examples "back url", "/procurement-support/energy_bill"

      context "when an alternative to energy bills is selected" do
        let(:framework_request) { create(:framework_request, energy_alternative: :different_format) }

        before { get :index, session: { framework_request_id: framework_request.id } }

        it "goes back to the energy alternative page" do
          expect(controller.view_assigns["back_url"]).to eq "/procurement-support/energy_alternative"
        end
      end
    end
  end

  describe "on edit" do
    let(:framework_request) { create(:framework_request, category: create(:request_for_help_category, flow: "energy"), energy_alternative:) }
    let(:energy_alternative) { nil }

    context "when coming in from the check-your-answers page" do
      let(:framework_support_form) { { framework_support_form: { source: "change_link" } } }
      let(:params) { { id: framework_request.id, **framework_support_form } }

      before { get :edit, params: }

      it "goes back to the check-your-answers page" do
        expect(controller.view_assigns["back_url"]).to eq "/procurement-support/#{framework_request.id}"
      end
    end

    context "when coming in from elsewhere" do
      let(:params) { { id: framework_request.id } }

      context "when the user selected to upload bills straight away" do
        let(:energy_alternative) { nil }

        before do
          get :edit, params:
        end

        it "goes back to the energy bill page" do
          expect(controller.view_assigns["back_url"]).to eq "/procurement-support/#{framework_request.id}/energy_bill/edit"
        end
      end

      context "when the user selected to upload bills via energy alternative" do
        let(:energy_alternative) { :different_format }

        before do
          get :edit, params:
        end

        it "goes back to the energy alternative page" do
          expect(controller.view_assigns["back_url"]).to eq "/procurement-support/#{framework_request.id}/energy_alternative/edit"
        end
      end
    end
  end

  describe "on update" do
    let(:framework_request) { create(:framework_request, category: create(:request_for_help_category, flow: "energy")) }

    before do
      patch :update, params: { id: framework_request.id }
    end

    it "redirects to the check-your-answers page" do
      expect(response).to redirect_to("/procurement-support/#{framework_request.id}")
    end
  end
end
