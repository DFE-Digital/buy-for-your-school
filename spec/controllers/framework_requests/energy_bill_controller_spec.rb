require "./spec/support/shared/framework_request_controllers"

describe FrameworkRequests::EnergyBillController, type: :controller do
  include_examples "back url", "/procurement-support/energy_request_about"

  context "when the user has no bill" do
    before { post :create, params: { framework_support_form: { have_energy_bill: "false" } } }

    it "redirects to the energy alternative page" do
      expect(response).to redirect_to "/procurement-support/energy_alternative"
    end
  end

  context "when the user has a bill" do
    include_examples "sign-in redirects", { framework_support_form: { have_energy_bill: "true" } }
  end
end
