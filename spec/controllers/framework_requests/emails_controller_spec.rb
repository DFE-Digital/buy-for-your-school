require "./spec/support/shared/framework_request_controllers"

describe FrameworkRequests::EmailsController, type: :controller do
  include_examples "back url", "/procurement-support/name"

  context "when the user has chosen to upload a bill" do
    let(:framework_request) { create(:framework_request, is_energy_request: true, energy_request_about: "energy_contract", have_energy_bill: true) }

    it "redirects to the bill upload page" do
      post :create, session: { framework_request_id: framework_request.id }
      expect(response).to redirect_to "/procurement-support/bill_uploads"
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
