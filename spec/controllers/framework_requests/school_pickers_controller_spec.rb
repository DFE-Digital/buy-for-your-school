require "./spec/support/shared/framework_request_controllers"

describe FrameworkRequests::SchoolPickersController, type: :controller do
  let(:framework_request) { create(:framework_request) }

  describe "create" do
    let(:session) { { framework_request_id: framework_request.id } }
    let(:params) { { framework_support_form: { school_urns: %w[1 2] } } }

    it "redirects to the school confirmation page" do
      post(:create, params:, session:)
      expect(response).to redirect_to "/procurement-support/confirm_schools?#{params.to_query}"
    end
  end

  describe "update" do
    let(:framework_support_form) { { framework_support_form: { school_urns: %w[1 2] } } }
    let(:params) { { id: framework_request.id, **framework_support_form } }

    it "redirects to the school confirmation edit page" do
      patch(:update, params:)
      expect(response).to redirect_to "/procurement-support/#{framework_request.id}/confirm_schools/edit?#{framework_support_form.to_query}"
    end
  end

  describe "index" do
    describe "back url" do
      context "when the user is signed in" do
        before { user_is_signed_in(user:) }

        context "and belongs to a single organisation" do
          let(:user) { build(:user, :one_supported_school) }

          include_examples "back url", "/procurement-support/confirm_sign_in"
        end

        context "and belongs to multiple organisations" do
          let(:user) { build(:user, :many_supported_schools) }

          include_examples "back url", "/procurement-support/select_organisation"
        end
      end

      context "when the user is a guest" do
        let(:framework_support_form) { { framework_support_form: { org_confirm: "true", school_type: "group" } } }

        it "goes back to the confirm organisation step" do
          get(:index)
          expect(controller.view_assigns["back_url"]).to eq "/procurement-support/confirm_organisation?#{framework_support_form.to_query}"
        end
      end
    end
  end

  describe "edit" do
    describe "back url" do
      context "when the source is the change link" do
        let(:framework_support_form) { { framework_support_form: { source: "change_link" } } }
        let(:params) { { id: framework_request.id, **framework_support_form } }

        it "goes back to the request" do
          get(:edit, params:)
          expect(controller.view_assigns["back_url"]).to eq "/procurement-support/#{framework_request.id}"
        end
      end

      context "when there is no source" do
        let(:framework_support_form) { { framework_support_form: { school_type: "group", org_confirm: true } } }
        let(:params) { { id: framework_request.id } }

        it "goes back to the confirm organisation step" do
          get(:edit, params:)
          expect(controller.view_assigns["back_url"]).to eq "/procurement-support/#{framework_request.id}/confirm_organisation/edit?#{framework_support_form.to_query}"
        end
      end
    end
  end
end
