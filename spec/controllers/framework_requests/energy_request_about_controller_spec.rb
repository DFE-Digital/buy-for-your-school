require "./spec/support/shared/framework_request_controllers"

describe FrameworkRequests::EnergyRequestAboutController, type: :controller do
  include_examples "back url", "/procurement-support/energy_request"

  context "when it is about an energy contract" do
    before { post :create, params: { framework_support_form: { energy_request_about: "energy_contract" } } }

    it "redirects to the energy bill page" do
      expect(response).to redirect_to "/procurement-support/energy_bill"
    end
  end

  context "when it is not about an energy contract" do
    include_examples "sign-in redirects", { framework_support_form: { energy_request_about: "not_energy_contract" } }
  end
end
