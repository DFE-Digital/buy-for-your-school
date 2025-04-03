describe "Agent can view contract handover task list", :js do
  include_context "with an agent"

  let(:support_case) { create(:support_case, support_level: "L4") }
  let(:file_1) { fixture_file_upload(Rails.root.join("spec/fixtures/support/text-file.txt"), "text/plain") }
  let(:file_2) { fixture_file_upload(Rails.root.join("spec/fixtures/support/another-text-file.txt"), "text/plain") }
  let(:document_uploader) { support_case.document_uploader(files: [file_1, file_2]) }
  let(:given_roles) { %w[procops] }
  let(:support_agent) { create(:user, :caseworker) }
  let(:agent) { Support::Agent.find_or_create_by_user(support_agent).tap { |agent| agent.update!(roles: given_roles) } }
  let!(:recipient) { create(:support_contract_recipient, support_case:, email: "recipient@example.com") }

  before do
    Current.agent = agent
  end

  specify "contract handover task list status" do
    visit support_case_path(support_case, anchor: "tasklist")

    expect(find("#handover_contract-4-status")).to have_text("Cannot start")

    create(:support_contract_recipient, support_case:, dsi_uid: user.dfe_sign_in_uid, email: user.email)

    expect(find("#handover_contract-4-status")).to have_text("Cannot start")

    document_uploader.save_contract_handover_pack!

    expect(find("#handover_contract-4-status")).to have_text("Cannot start")

    support_case.update!(has_uploaded_contract_handovers: true)

    visit my_procurements_download_handover_pack_path(support_case)

    find_all(".govuk-summary-list__row a")[0].click

    recipient.update!(has_downloaded_documents: true)

    visit support_case_path(support_case, anchor: "tasklist")

    expect(find("#handover_contract-4-status")).to have_text("In progress")

    visit my_procurements_download_handover_pack_path(support_case)

    find_all(".govuk-summary-list__row a")[1].click

    choose "Yes, I have downloaded all documents"

    click_button "Continue"

    expect(find("#my_procurements_task-1-status")).to have_text("Complete")

    visit support_case_path(support_case, anchor: "tasklist")

    expect(find("#handover_contract-4-status")).to have_text("Complete")
  end
end
