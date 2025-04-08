require "rails_helper"

describe "Evaluator can see task list", :js do
  let(:support_case) { create(:support_case) }
  let(:user) { create(:user) }
  let(:file_1) { fixture_file_upload(Rails.root.join("spec/fixtures/support/text-file.txt"), "text/plain") }
  let(:file_2) { fixture_file_upload(Rails.root.join("spec/fixtures/support/another-text-file.txt"), "text/plain") }
  let(:document_uploader) { support_case.document_uploader(files: [file_1, file_2]) }
  let!(:support_evaluator) { create(:support_evaluator, support_case:, email: user.email, dsi_uid: user.dfe_sign_in_uid) }
  let(:given_roles) { %w[procops] }
  let(:support_agent) { create(:user, :caseworker) }
  let(:agent) { Support::Agent.find_or_create_by_user(support_agent).tap { |agent| agent.update!(roles: given_roles) } }

  before do
    Current.agent = agent
  end

  specify "Authenticating and seeing the task list" do
    Current.user = user
    user_exists_in_dfe_sign_in(user:)

    user_is_signed_in(user:)

    visit evaluation_task_path(support_case)

    expect(page).to have_text("Evaluator task list")
    expect(page).to have_text("Download documents")
    expect(page).to have_text("Upload evaluation scoring document")
    expect(page).to have_text("Evaluation approved by DfE")
  end

  specify "Authenticating when not an evaluator" do
    Current.user = user
    user_exists_in_dfe_sign_in(user:)

    visit evaluation_task_path(support_case)

    expect(page).not_to have_text("Evaluator task list")
  end

  specify "Verify evaluation unique link when evaluator already authenticated" do
    Current.user = user
    user_exists_in_dfe_sign_in(user:)

    user_is_signed_in(user:)

    visit evaluation_verify_evaluators_unique_link_path(support_case)

    expect(page).to have_text("Evaluator task list")
  end

  specify "Verify evaluation unique link when evaluator not authenticated" do
    Current.user = user
    user_exists_in_dfe_sign_in(user:)

    visit evaluation_verify_evaluators_unique_link_path(support_case)

    expect(page).to have_text("Complete procurement evaluation")
    expect(page).not_to have_text("Evaluator task list")
  end

  specify "Verify the upload completed documents link when evaluation is not approved" do
    Current.user = user
    user_exists_in_dfe_sign_in(user:)

    user_is_signed_in(user:)

    document_uploader.save!

    visit evaluation_download_document_path(support_case)

    find_all(".govuk-summary-list__row a")[0].click
    find_all(".govuk-summary-list__row a")[1].click

    support_evaluator.update!(has_downloaded_documents: true, has_uploaded_documents: true)

    document_uploader.save_evaluation_document!(user, true)

    visit evaluation_task_path(support_case)

    expect(page).to have_link("Upload evaluation scoring document")
  end

  specify "Verify the upload completed documents link when evaluation is approved" do
    Current.user = user
    user_exists_in_dfe_sign_in(user:)

    user_is_signed_in(user:)

    document_uploader.save!

    visit evaluation_download_document_path(support_case)

    find_all(".govuk-summary-list__row a")[0].click
    find_all(".govuk-summary-list__row a")[1].click

    support_evaluator.update!(has_downloaded_documents: true, has_uploaded_documents: true, evaluation_approved: true)

    document_uploader.save_evaluation_document!(user, true)

    visit evaluation_task_path(support_case)

    expect(page).to have_link("Upload evaluation scoring document")
  end

  specify "Verify the evaluation scoring document task status" do
    Current.user = user
    user_exists_in_dfe_sign_in(user:)

    user_is_signed_in(user:)

    document_uploader.save!

    support_evaluator.update!(has_downloaded_documents: true)

    visit evaluation_task_path(support_case)

    expect(find("#evaluator_task-2-status")).to have_text("To do")

    document_uploader.save_evaluation_document!(user, true)

    support_evaluator.reload

    visit evaluation_task_path(support_case)

    expect(find("#evaluator_task-2-status")).to have_text("In progress")

    support_evaluator.update!(has_uploaded_documents: true)

    support_evaluator.reload

    visit evaluation_task_path(support_case)

    expect(find("#evaluator_task-2-status")).to have_text("Complete")
  end
end
