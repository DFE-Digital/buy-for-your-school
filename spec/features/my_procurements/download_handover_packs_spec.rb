require "rails_helper"
describe "School buying professional can see uploaded contract handover packs", :js do
  let(:support_case) { create(:support_case) }
  let(:user) { create(:user) }
  let(:file_1) { fixture_file_upload(Rails.root.join("spec/fixtures/support/text-file.txt"), "text/plain") }
  let(:file_2) { fixture_file_upload(Rails.root.join("spec/fixtures/support/another-text-file.txt"), "text/plain") }
  let(:document_uploader) { support_case.document_uploader(files: [file_1, file_2]) }
  let(:given_roles) { %w[procops] }
  let(:support_agent) { create(:user, :caseworker) }
  let(:agent) { Support::Agent.find_or_create_by_user(support_agent).tap { |agent| agent.update!(roles: given_roles) } }

  before do
    Current.agent = agent
  end

  specify "School buying professional can download contract handover packs" do
    create(:support_contract_recipient, support_case:, dsi_uid: user.dfe_sign_in_uid, email: user.email, first_name: "Momo", last_name: "Taro")

    Current.user = user

    user_exists_in_dfe_sign_in(user:)

    user_is_signed_in(user:)

    expect { document_uploader.save_contract_handover_pack! }.to change { support_case.upload_contract_handovers.count }.from(0).to(2)

    visit my_procurements_task_path(support_case)

    expect(page).to have_text("Procurement task list")

    expect(find("#my_procurements_task-1-status")).to have_text("To do")

    visit my_procurements_download_handover_pack_path(support_case)

    expect(page).to have_text("Download contract handover pack")

    expect(page).to have_content("text-file.txt")

    expect(page).to have_content("another-text-file.txt")

    find_all(".govuk-summary-list__row a")[0].click

    visit my_procurements_task_path(support_case)

    expect(find("#my_procurements_task-1-status")).to have_text("To do")

    expect(Support::Interaction.count).to eq(3)
    expect(Support::Interaction.all[2].body).to eq("text-file.txt added by Procurement Specialist")
    expect(Support::Interaction.all[1].body).to eq("another-text-file.txt added by Procurement Specialist")
    expect(Support::Interaction.all[0].body).to eq("text-file.txt downloaded by school buyer Momo Taro")

    visit my_procurements_download_handover_pack_path(support_case)

    find_all(".govuk-summary-list__row a")[1].click

    choose "Yes, I have downloaded all documents"

    click_button "Continue"

    support_case.reload

    visit my_procurements_task_path(support_case)

    expect(find("#my_procurements_task-1-status")).to have_text("Complete")

    expect(Support::Interaction.count).to eq(5)
    expect(Support::Interaction.all[0].body).to eq("All documents downloaded by school buyer Momo Taro")
    expect(Support::Interaction.all[1].body).to eq("another-text-file.txt downloaded by school buyer Momo Taro")
  end
end
