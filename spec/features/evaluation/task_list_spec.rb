require "rails_helper"

describe "Evaluator can see task list", :js do
  let(:support_case) { create(:support_case) }
  let(:user) { create(:user) }

  specify "Authenticating and seeing the task list" do
    create(:support_evaluator, support_case:, dsi_uid: user.dfe_sign_in_uid)
    Current.user = user
    user_exists_in_dfe_sign_in(user:)
    visit "/"
    click_start

    visit evaluation_task_path(support_case)

    expect(page).to have_text("Evaluator task list")
  end

  specify "Authenticating when not an evaluator" do
    create(:support_evaluator, support_case:)
    Current.user = user
    user_exists_in_dfe_sign_in(user:)
    visit "/"
    click_start

    visit evaluation_task_path(support_case)

    expect(page).not_to have_text("Evaluator task list")
    expect(page).to have_text("You aren’t an evaluator for this procurement")
  end
end
