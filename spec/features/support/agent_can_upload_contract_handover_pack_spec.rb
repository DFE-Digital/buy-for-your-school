require "rails_helper"

RSpec.feature "Agent can upload contract handover pack", :js, :with_csrf_protection do
  include_context "with an agent"

  before do
    Current.agent = agent
  end

  let(:support_case) { create(:support_case) }
  let(:file_1) { fixture_file_upload(Rails.root.join("spec/fixtures/support/text-file.txt"), "text/plain") }
  let(:file_2) { fixture_file_upload(Rails.root.join("spec/fixtures/support/another-text-file.txt"), "text/plain") }
  let(:document_uploader) { support_case.document_uploader(files: [file_1, file_2]) }

  specify "when no files are selected" do
    visit edit_support_case_upload_contract_handover_path(case_id: support_case)

    expect(page).to have_text("Upload handover pack")
    expect(page).to have_text("Upload a file")
    expect(page).to have_text("Have you uploaded all documents?")

    click_button "Continue"

    expect(page).to have_text("There is a problem")
    expect(page).to have_text("Select files to upload")
  end

  specify "when files are uploaded and confirmation chosen as No (In progress)" do
    support_case.update!(has_uploaded_contract_handovers: false)

    expect { document_uploader.save_contract_handover_pack! }.to change { support_case.upload_contract_handovers.count }.from(0).to(2)
    expect(support_case.upload_contract_handovers.pluck(:file_name)).to contain_exactly("text-file.txt", "another-text-file.txt")
    expect(support_case.upload_contract_handovers.map { |a| a.file.attached? }.all?).to eq(true)

    visit support_case_path(support_case, anchor: "tasklist")

    expect(find("#handover_contract-2-status")).to have_text("In progress")
  end

  specify "when files are uploaded and confirmation chosen as Yes (Complete)" do
    support_case.update!(has_uploaded_contract_handovers: true)

    expect { document_uploader.save_contract_handover_pack! }.to change { support_case.upload_contract_handovers.count }.from(0).to(2)
    expect(support_case.upload_contract_handovers.pluck(:file_name)).to contain_exactly("text-file.txt", "another-text-file.txt")
    expect(support_case.upload_contract_handovers.map { |a| a.file.attached? }.all?).to eq(true)

    visit support_case_path(support_case, anchor: "tasklist")

    expect(find("#handover_contract-2-status")).to have_text("Complete")

    expect(Support::Interaction.count).to eq(2)
    expect(Support::Interaction.last.body).to eq("text-file.txt added by Procurement Specialist")
    expect(Support::Interaction.first.body).to eq("another-text-file.txt added by Procurement Specialist")

    visit edit_support_case_upload_contract_handover_path(case_id: support_case)

    choose("No")

    click_button "Continue"

    expect(Support::Interaction.count).to eq(3)
    expect(Support::Interaction.first.body).to eq("Upload documents marked incomplete by Procurement Specialist")
  end

  specify "viewing uploaded files" do
    support_case.update!(has_uploaded_contract_handovers: true)
    document_uploader.save_contract_handover_pack!

    visit edit_support_case_upload_contract_handover_path(case_id: support_case)

    expect(page).to have_content("text-file.txt")
    expect(page).to have_content("another-text-file.txt")

    find_all(".case-files__file-remove a")[0].click

    expect(find(".govuk-button--warning")).to have_content("Delete")

    expect(page).to have_content("text-file.txt")
  end

  specify "When uploaded files are deleted, download files data will be deleted" do
    support_case.update!(has_uploaded_contract_handovers: true)
    create(:support_contract_recipient, support_case:, dsi_uid: user.dfe_sign_in_uid, email: user.email)

    document_uploader.save_contract_handover_pack!

    visit my_procurements_download_handover_pack_path(support_case)

    expect(page).to have_text("Download contract handover pack")

    expect(page).to have_content("text-file.txt")
    expect(page).to have_content("another-text-file.txt")

    find_all("dl .govuk-link")[0].click

    expect(Support::DownloadContractHandover.count).to eq(1)

    visit edit_support_case_upload_contract_handover_path(case_id: support_case)

    find_all(".case-files__file-remove a")[0].click

    click_link "Delete"

    expect(Support::DownloadContractHandover.count).to eq(0)

    expect(Support::Interaction.count).to eq(4)
    expect(Support::Interaction.first.body).to eq("text-file.txt deleted by Procurement Specialist")

    visit support_case_path(support_case, anchor: "case-history")
    expect(page).to have_text "text-file.txt deleted by Procurement Specialist"
  end

  specify "when all files are deleted" do
    support_case.reload

    support_case.upload_contract_handovers(&:destroy!)

    support_case.reload

    support_case.update!(has_uploaded_contract_handovers: false)

    expect(support_case.upload_contract_handovers.count).to eq(0)

    visit support_case_path(support_case, anchor: "tasklist")

    expect(find("#handover_contract-2-status", wait: 10)).to have_text("To do")
  end
end
