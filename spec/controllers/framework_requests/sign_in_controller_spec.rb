require "./spec/support/shared/framework_request_controllers"

describe FrameworkRequests::SignInController, type: :controller do
  it "redirects to the organisation type page" do
    params = { framework_support_form: { dsi: "false" } }
    post :create, params: params
    expect(response).to redirect_to "/procurement-support/organisation_type?#{params.to_query}"
  end

  describe "back url" do
    context "when a back url is provided" do
      let(:back_url) { "/procurement-support/energy_bill" }

      it "goes back to the provided url" do
        get :index, params: { back_to: Base64.encode64(back_url) }
        expect(controller.view_assigns["back_url"]).to eq "#{back_url}?"
      end
    end

    context "when a back url is not provided" do
      include_examples "back url", "/procurement-support/energy_request"
    end
  end
end
