require "rails_helper"

describe "Evaluator can see task list", :js do
  let(:support_case) { create(:support_case) }
  let(:user) { create(:user) }

  specify "Authenticating and seeing the task list" do
    create(:support_evaluator, support_case:, dsi_uid: user.dfe_sign_in_uid, email: user.email)
    Current.user = user
    user_exists_in_dfe_sign_in(user:)

    user_is_signed_in(user:)

    visit evaluation_task_path(support_case)

    expect(page).to have_text("Evaluator task list")
  end

  specify "Authenticating when not an evaluator" do
    create(:support_evaluator, support_case:)
    Current.user = user
    user_exists_in_dfe_sign_in(user:)

    visit evaluation_task_path(support_case)

    expect(page).not_to have_text("Evaluator task list")
  end
end
