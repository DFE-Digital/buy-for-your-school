require "rails_helper"

RSpec.feature "Evaluator can can upload completed documents", :js, :with_csrf_protection do
  let(:support_case) { create(:support_case) }
  let(:user) { create(:user) }
  let(:file_1) { fixture_file_upload(Rails.root.join("spec/fixtures/support/text-file.txt"), "text/plain") }
  let(:file_2) { fixture_file_upload(Rails.root.join("spec/fixtures/support/another-text-file.txt"), "text/plain") }
  let(:document_uploader) { support_case.document_uploader(files: [file_1, file_2]) }
  let!(:support_evaluator) { create(:support_evaluator, support_case:, email: user.email, dsi_uid: user.dfe_sign_in_uid) }

  before do
    Current.user = user
    user_exists_in_dfe_sign_in(user:)
    user_is_signed_in(user:)
  end

  def visit_and_click_link(path, link_index)
    visit path
    find_all(".govuk-summary-list__row a")[link_index].click
  end

  def upload_documents
    document_uploader.save!
    visit_and_click_link(evaluation_download_document_path(support_case), 0)
    visit_and_click_link(evaluation_download_document_path(support_case), 1)
  end

  specify "when no files are selected" do
    upload_documents

    visit evaluation_upload_completed_document_path(support_case)

    expect(page).to have_text("Upload evaluation")
    expect(page).to have_text("Upload a file")
    expect(page).to have_text("Have you uploaded all the completed documents?")

    click_button "Continue"

    expect(page).to have_text("There is a problem")
    expect(page).to have_text("Select files to upload")
    expect(page).to have_text("Please confirm that you uploaded all documents")
  end

  specify "when files are uploaded and confirmation choosen as No (In progress)" do
    upload_documents

    support_evaluator.update!(has_uploaded_documents: false)

    expect { document_uploader.save_evaluation_document!(user.email) }.to change { support_case.evaluators_upload_documents.count }.from(0).to(2)
    expect(support_case.evaluators_upload_documents.pluck(:file_name)).to contain_exactly("text-file.txt", "another-text-file.txt")
    expect(support_case.evaluators_upload_documents.map { |a| a.file.attached? }.all?).to eq(true)

    visit evaluation_task_path(support_case)

    expect(find("#evaluator_task-2-status")).to have_text("In progress")
  end

  specify "when files are uploaded and confirmation choosen as Yes (Complete)" do
    upload_documents

    support_evaluator.update!(has_uploaded_documents: true)

    expect { document_uploader.save_evaluation_document!(user.email) }.to change { support_case.evaluators_upload_documents.count }.from(0).to(2)
    expect(support_case.evaluators_upload_documents.pluck(:file_name)).to contain_exactly("text-file.txt", "another-text-file.txt")
    expect(support_case.evaluators_upload_documents.map { |a| a.file.attached? }.all?).to eq(true)

    visit evaluation_task_path(support_case)

    expect(find("#evaluator_task-2-status")).to have_text("Complete")
  end

  specify "viewing uploaded files" do
    upload_documents

    support_evaluator.update!(has_uploaded_documents: true)

    document_uploader.save_evaluation_document!(user.email)

    visit evaluation_upload_completed_document_path(support_case)

    expect(page).to have_content("text-file.txt")
    expect(page).to have_content("another-text-file.txt")

    find_all(".case-files__file-remove a")[0].click

    expect(find(".govuk-button--warning")).to have_content("Delete")

    expect(page).to have_content("text-file.txt")
  end

  specify "when all files are deleted" do
    upload_documents

    support_case.reload

    support_case.evaluators_upload_documents(&:destroy!)

    support_case.reload

    support_evaluator.update!(has_uploaded_documents: nil)

    expect(support_case.evaluators_upload_documents.count).to eq(0)

    visit evaluation_task_path(support_case)

    expect(find("#evaluator_task-2-status", wait: 10)).to have_text("To do")
  end
end
