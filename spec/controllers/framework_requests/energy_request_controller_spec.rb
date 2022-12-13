require "./spec/support/shared/framework_request_controllers"

describe FrameworkRequests::EnergyRequestController, type: :controller do
  include_examples "back url", "/procurement-support"

  context "when it is an energy request" do
    before { post :create, params: { framework_support_form: { is_energy_request: "true" } } }

    it "redirects to the energy request about page" do
      expect(response).to redirect_to "/procurement-support/energy_request_about"
    end
  end

  context "when it is not an energy request" do
    include_examples "sign-in redirects", { framework_support_form: { is_energy_request: "false" } }
  end
end
