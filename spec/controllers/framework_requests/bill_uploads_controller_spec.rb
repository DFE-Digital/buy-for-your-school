require "./spec/support/shared/framework_request_controllers"

describe FrameworkRequests::BillUploadsController, type: :controller do
  it "redirects to the message page" do
    post :create
    expect(response).to redirect_to "/procurement-support/message"
  end

  describe "back url" do
    context "when the user is signed in" do
      before { user_is_signed_in(user:) }

      context "when the user belongs to one organisation" do
        let(:user) { build(:user, :one_supported_school) }

        before { allow(controller).to receive(:last_energy_path).and_return("last_energy_path") }

        include_examples "back url", "last_energy_path"
      end

      context "when the user belongs to multiple organisations" do
        let(:user) { build(:user, :many_supported_schools) }

        include_examples "back url", "/procurement-support/select_organisation"
      end
    end

    context "when the user is not signed in" do
      include_examples "back url", "/procurement-support/email"
    end
  end
end
