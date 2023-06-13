require "./spec/support/shared/framework_request_controllers"

describe FrameworkRequests::MessagesController, type: :controller do
  context "when feature :energy_bill_flow is not enabled" do
    let(:framework_request) { create(:framework_request) }

    before { Flipper.disable(:energy_bill_flow) }

    it "redirects to the category page" do
      post :create, session: { framework_request_id: framework_request.id }
      expect(response).to redirect_to "/procurement-support/categories"
    end
  end

  context "when the user has chosen to upload a bill" do
    let(:framework_request) { create(:framework_request, is_energy_request: true, energy_request_about: "energy_contract", have_energy_bill: true) }

    it "redirects to the category page" do
      post :create, session: { framework_request_id: framework_request.id }
      expect(response).to redirect_to "/procurement-support/categories"
    end
  end

  context "when the user has chosen not to upload a bill" do
    let(:framework_request) { create(:framework_request, is_energy_request: false) }

    it "redirects to the category page" do
      post :create, session: { framework_request_id: framework_request.id }
      expect(response).to redirect_to "/procurement-support/categories"
    end
  end

  describe "back url" do
    context "when the user is signed in" do
      before { user_is_signed_in(user:) }

      context "when the user belongs to one organisation" do
        let(:user) { build(:user, :one_supported_school) }

        before { allow(controller).to receive(:last_energy_path).and_return("last_energy_path") }

        include_examples "back url", "last_energy_path"

        context "when feature :energy_bill_flow is not enabled" do
          before { Flipper.disable(:energy_bill_flow) }

          include_examples "back url", "/procurement-support/select_organisation"
        end
      end

      context "when the user belongs to multiple organisations" do
        let(:user) { build(:user, :many_supported_schools) }

        include_examples "back url", "/procurement-support/select_organisation"
      end
    end

    context "when the user is not signed in" do
      include_examples "back url", "/procurement-support/email"
    end

    context "when the user has chosen to upload a bill" do
      let(:framework_request) { create(:framework_request, is_energy_request: true, energy_request_about: "energy_contract", have_energy_bill: true) }

      it "goes back to the bill upload page" do
        get :index, session: { framework_request_id: framework_request.id }
        expect(controller.view_assigns["back_url"]).to eq "/procurement-support/bill_uploads"
      end
    end
  end
end
