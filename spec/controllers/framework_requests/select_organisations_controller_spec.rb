require "./spec/support/shared/framework_request_controllers"

describe FrameworkRequests::SelectOrganisationsController, type: :controller do
  before do
    user_is_signed_in
    allow(controller).to receive(:last_energy_path).and_return "last_energy_path"
  end

  include_examples "back url", "last_energy_path"

  context "when the user has chosen to upload a bill" do
    let(:framework_request) { create(:framework_request, is_energy_request: true, energy_request_about: "energy_contract", have_energy_bill: true) }

    it "redirects to the bill upload page" do
      post :create, session: { framework_request_id: framework_request.id }
      expect(response).to redirect_to "/procurement-support/upload-your-bill"
    end
  end

  context "when the user has chosen not to upload a bill" do
    let(:framework_request) { create(:framework_request, is_energy_request: false) }

    it "redirects to the message page" do
      post :create, session: { framework_request_id: framework_request.id }
      expect(response).to redirect_to "/procurement-support/message"
    end
  end
end
