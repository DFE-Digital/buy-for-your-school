require "rails_helper"

describe "Evaluator can see evaluation approval by DfE", :js do
  let(:support_case) { create(:support_case) }
  let(:user) { create(:user) }
  let(:given_roles) { %w[procops] }
  let(:support_agent) { create(:user, :caseworker) }
  let(:agent) { Support::Agent.find_or_create_by_user(support_agent).tap { |agent| agent.update!(roles: given_roles) } }

  before do
    Current.agent = agent
  end

  specify "after authenticating" do
    create(:support_evaluator, support_case:, email: user.email, dsi_uid: user.dfe_sign_in_uid)

    Current.user = user
    user_exists_in_dfe_sign_in(user:)

    user_is_signed_in(user:)

    visit evaluation_evaluation_approved_path(support_case)

    expect(page).to have_text("Evaluation approved by DfE")
  end

  specify "before authenticating" do
    Current.user = user
    user_exists_in_dfe_sign_in(user:)

    visit evaluation_evaluation_approved_path(support_case)

    expect(page).not_to have_text("Evaluation approved by DfE")
  end
end
