require "rails_helper"

RSpec.feature "Agent can upload evaluation documents", :js, :with_csrf_protection do
  include_context "with an agent"

  let(:support_case) { create(:support_case) }
  let(:file_1) { fixture_file_upload(Rails.root.join("spec/fixtures/support/text-file.txt"), "text/plain") }
  let(:file_2) { fixture_file_upload(Rails.root.join("spec/fixtures/support/another-text-file.txt"), "text/plain") }
  let(:document_uploader) { support_case.document_uploader(files: [file_1, file_2]) }

  specify "when no files are selected" do
    visit edit_support_case_document_uploads_path(case_id: support_case)

    expect(page).to have_text("Upload documents")
    expect(page).to have_text("Upload a file")
    expect(page).to have_text("Have you uploaded all documents?")

    click_button "Continue"

    expect(page).to have_text("There is a problem")
    expect(page).to have_text("Select files to upload")
    expect(page).to have_text("Please confirm that you uploaded all documents")
  end

  specify "when files are uploaded and confirmation choosen as No (In progress)" do
    support_case.update!(has_uploaded_documents: false)

    expect { document_uploader.save! }.to change { support_case.upload_documents.count }.from(0).to(2)
    expect(support_case.upload_documents.pluck(:file_name)).to contain_exactly("text-file.txt", "another-text-file.txt")
    expect(support_case.upload_documents.map { |a| a.file.attached? }.all?).to eq(true)

    visit support_case_path(support_case, anchor: "tasklist")

    expect(find("#complete-evaluation-3-status")).to have_text("In progress")
  end

  specify "when files are uploaded and confirmation choosen as Yes (Complete)" do
    support_case.update!(has_uploaded_documents: true)

    expect { document_uploader.save! }.to change { support_case.upload_documents.count }.from(0).to(2)
    expect(support_case.upload_documents.pluck(:file_name)).to contain_exactly("text-file.txt", "another-text-file.txt")
    expect(support_case.upload_documents.map { |a| a.file.attached? }.all?).to eq(true)

    visit support_case_path(support_case, anchor: "tasklist")

    expect(find("#complete-evaluation-3-status")).to have_text("Complete")
  end

  specify "viewing uploaded files" do
    support_case.update!(has_uploaded_documents: true)
    document_uploader.save!

    visit edit_support_case_document_uploads_path(case_id: support_case)

    expect(page).to have_content("text-file.txt")
    expect(page).to have_content("another-text-file.txt")

    find_all(".case-files__file-remove a")[0].click

    expect(find(".govuk-button--warning")).to have_content("Delete")

    expect(page).to have_content("text-file.txt")
  end

  specify "when all files are deleted" do
    support_case.reload

    support_case.upload_documents(&:destroy!)

    support_case.reload

    support_case.update!(has_uploaded_documents: nil)

    expect(support_case.upload_documents.count).to eq(0)

    visit support_case_path(support_case, anchor: "tasklist")

    expect(find("#complete-evaluation-3-status", wait: 10)).to have_text("To do")
  end
end
