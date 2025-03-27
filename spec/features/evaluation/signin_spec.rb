require "rails_helper"

RSpec.describe "evaluator signin request", type: :request do
  let(:user) { create(:user) }
  let(:support_case) { create(:support_case) }

  describe "GET evaluation_task_path" do
    context "when user is not signed in" do
      it "redirects to the evaluation_signin_path" do
        get evaluation_task_path(support_case)
        expect(response).to redirect_to(evaluation_signin_path(support_case))
      end
    end

    context "when user is signed in" do
      it "redirects to the evaluation_task_path" do
        create(:support_evaluator, support_case:, email: user.email, dsi_uid: user.dfe_sign_in_uid)
        user_is_signed_in(user:)
        get evaluation_verify_evaluators_unique_link_path(support_case)
        expect(response).to redirect_to(evaluation_task_path(support_case))
      end
    end
  end
end
