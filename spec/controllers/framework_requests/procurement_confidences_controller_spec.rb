describe FrameworkRequests::ProcurementConfidencesController, type: :controller do
  it "redirects to the special requirements page" do
    post :create, params: { framework_support_form: { confidence_level: "very_confident" } }
    expect(response).to redirect_to "/procurement-support/special_requirements"
  end

  describe "back url" do
    context "when the user has chosen to upload a bill" do
      let(:framework_request) { create(:framework_request, is_energy_request: true, energy_request_about: "energy_contract", have_energy_bill: true) }

      it "goes back to the message page" do
        get :index, session: { framework_request_id: framework_request.id }
        expect(controller.view_assigns["back_url"]).to eq "/procurement-support/message"
      end
    end

    context "when the user has chosen not to upload a bill" do
      let(:framework_request) { create(:framework_request, is_energy_request: false) }

      it "goes back to the procurement amount page" do
        get :index, session: { framework_request_id: framework_request.id }
        expect(controller.view_assigns["back_url"]).to eq "/procurement-support/procurement_amount"
      end
    end
  end
end
