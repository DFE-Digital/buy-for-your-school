describe FrameworkRequests::SpecialRequirementsController, type: :controller do
  let(:framework_request) { create(:framework_request, is_energy_request:, energy_request_about:, have_energy_bill:) }
  let(:is_energy_request) { false }
  let(:energy_request_about) { nil }
  let(:have_energy_bill) { false }

  it "redirects to the framework request page" do
    params = { framework_support_form: { special_requirements_choice: "no" } }
    session = { framework_request_id: framework_request.id }
    post(:create, params:, session:)
    expect(response).to redirect_to "/procurement-support/#{framework_request.id}"
  end

  describe "back url" do
    context "when the user has chosen to upload a bill" do
      let(:is_energy_request) { true }
      let(:energy_request_about) { "energy_contract" }
      let(:have_energy_bill) { true }

      it "goes back to the categories page" do
        get :index, session: { framework_request_id: framework_request.id }
        expect(controller.view_assigns["back_url"]).to eq "/procurement-support/categories"
      end
    end

    context "when the user has chosen not to upload a bill" do
      let(:is_energy_request) { false }
      let(:energy_request_about) { nil }
      let(:have_energy_bill) { false }

      it "goes back to procurement amount page" do
        get :index, session: { framework_request_id: framework_request.id }
        expect(controller.view_assigns["back_url"]).to eq "/procurement-support/procurement_amount"
      end
    end
  end
end
