require "rails_helper"

describe "Agent can review evaluations", :js, :with_csrf_protection do
  include_context "with an agent"

  let(:support_case) { create(:support_case, email: user.email) }
  let(:file_1) { fixture_file_upload(Rails.root.join("spec/fixtures/support/text-file.txt"), "text/plain") }
  let(:file_2) { fixture_file_upload(Rails.root.join("spec/fixtures/support/another-text-file.txt"), "text/plain") }
  let(:document_uploader) { support_case.document_uploader(files: [file_1, file_2]) }

  before do
    Current.agent = agent
  end

  def send_email_to_evaluators(support_case)
    create(:support_email, :inbox, ticket: support_case, outlook_conversation_id: "OCID1", subject: "Email Evaluators", recipients: [{ "name" => "Test 1", "address" => "test1@email.com" }], unique_body: "Email 1", is_read: false)
    support_case.update!(sent_email_to_evaluators: true)
  end

  specify "When agent approve correctly completed evaluations" do
    support_case.evaluators.create!(first_name: "Momo", last_name: "Taro", email: "email@address", has_uploaded_documents: true)

    support_case.update!(evaluation_due_date: Date.tomorrow, has_uploaded_documents: true)

    document_uploader.save!

    document_uploader.save_evaluation_document!(user, true)

    send_email_to_evaluators(support_case)

    visit support_case_path(support_case, anchor: "tasklist")

    expect(find("#complete-evaluation-1-status")).to have_text("Complete")
    expect(find("#complete-evaluation-2-status")).to have_text("Complete")
    expect(find("#complete-evaluation-3-status")).to have_text("Complete")
    expect(find("#complete-evaluation-4-status")).to have_text("Complete")
    expect(find("#complete-evaluation-5-status")).to have_text("To do")

    visit edit_support_case_review_evaluation_path(support_case)

    expect(page).to have_content("Review evaluations")
    expect(page).to have_content("Tick which evaluations have been correctly completed")
    expect(page).to have_content("email@address")
    expect(page).to have_content("View Momo Taro's evaluation files")

    support_case.evaluators.update_all(evaluation_approved: true)

    visit edit_support_case_review_evaluation_path(support_case)

    expect(find_all(".govuk-checkboxes__input")[0]).to be_checked

    visit support_case_path(support_case, anchor: "tasklist")

    expect(find("#complete-evaluation-5-status")).to have_text("Complete")

    expect(Support::Interaction.count).to eq(4)
    expect(Support::Interaction.first.body).to eq("another-text-file.txt added by evaluator Procurement Specialist")

    visit edit_support_case_review_evaluation_path(support_case)

    find_all(".govuk-checkboxes__input")[0].click

    expect(find_all(".govuk-checkboxes__input")[0]).not_to be_checked

    click_button "Continue"

    expect(Support::Interaction.count).to eq(5)

    expect(Support::Interaction.first.body).to eq("Evaluation marked incomplete by Procurement Specialist")

    support_case.evaluators.update_all(evaluation_approved: false)

    visit support_case_path(support_case, anchor: "tasklist")

    expect(find("#complete-evaluation-5-status")).to have_text("To do")
  end
end
