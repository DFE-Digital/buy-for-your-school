require "rails_helper"

describe SessionsController do
  let(:session) { {} }
  let(:user)    { build(:user) }

  around do |example|
    ClimateControl.modify(PROC_OPS_TEAM: "DSI Caseworkers") do
      example.run
    end
  end

  describe "post-login redirection" do
    before do
      auth = { "uid" => 123 }
      controller.request.env["omniauth.auth"] = auth
      allow(CreateUser).to receive(:new).with(auth:).and_return(-> { user })
      get :create, session:
    end

    context "when the user is internal" do
      let(:user) { create(:user, :caseworker) }

      it "redirects to the cms_entrypoint_path" do
        expect(response).to redirect_to(cms_entrypoint_path)
      end
    end

    context "when user logging in from RFH flow" do
      let(:session) { { faf_referrer: "/" } }

      it "redirects to confirm_sign_in_framework_requests_path" do
        expect(response).to redirect_to(confirm_sign_in_framework_requests_path)
      end
    end

    context "when user logging in from Specify" do
      it "redirects to dashboard_path" do
        expect(response).to redirect_to(dashboard_path)
      end
    end

    context "when user is invalid" do
      let(:user) { :invalid }

      it "redirects to root_path" do
        expect(response).to redirect_to(root_path)
      end
    end

    context "when user has no organisations" do
      let(:user) { :no_organisation }

      it "renders sessions/no_organisation_error" do
        expect(response).to render_template("sessions/no_organisation_error")
      end
    end

    context "when user has organisations but none are supported" do
      let(:user) { :unsupported }

      it "renders sessions/unsupported_organisation_error" do
        expect(response).to render_template("sessions/unsupported_organisation_error")
      end
    end

    context "when user logging in from unique_link evaluation journey" do
      let(:support_case) { create(:support_case) }
      let(:session) { { email_evaluator_link: evaluation_verify_evaluators_unique_link_path(support_case) } }

      before do
        session.delete(:email_school_buyer_link)
        session.delete(:school_buyer_signin_link)
      end

      it "redirects to evaluation_verify_evaluators_unique_link_path" do
        expect(response).to redirect_to(evaluation_verify_evaluators_unique_link_path(support_case))
      end
    end

    context "when user logging in from unique_link contract handover journey" do
      let(:support_case) { create(:support_case) }
      let(:session) { { email_school_buyer_link: my_procurements_task_path(support_case) } }

      before do
        session.delete(:email_evaluator_link)
        session.delete(:evaluator_signin_link)
      end

      it "redirects to my_procurements_verify_unique_link_path" do
        expect(response).to redirect_to(my_procurements_task_path(support_case))
      end
    end
  end
end
