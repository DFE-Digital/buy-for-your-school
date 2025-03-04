require "rails_helper"

describe "School buying professional can see procurement task list", :js do
  let(:support_case) { create(:support_case) }
  let(:user) { create(:user) }

  specify "Authenticating and seeing the procurement task list" do
    create(:support_contract_recipient, support_case:, dsi_uid: user.dfe_sign_in_uid, email: user.email)
    Current.user = user
    user_exists_in_dfe_sign_in(user:)

    user_is_signed_in(user:)

    visit my_procurements_task_path(support_case)

    expect(page).to have_text("Procurement task list")
    expect(page).to have_text("Download contract handover pack")
  end

  specify "Authenticating when not school buying professional" do
    create(:support_contract_recipient, support_case:)
    Current.user = user
    user_exists_in_dfe_sign_in(user:)

    visit my_procurements_task_path(support_case)

    expect(page).not_to have_text("Procurement task list")
    expect(page).not_to have_text("Download contract handover pack")
  end
end
