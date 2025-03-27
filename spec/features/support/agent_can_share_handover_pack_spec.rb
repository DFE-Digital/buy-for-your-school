require "rails_helper"

describe "Agent can share handover pack", :js, :with_csrf_protection do
  include_context "with an agent"

  let(:support_case) { create(:support_case) }
  let(:file_1) { fixture_file_upload(Rails.root.join("spec/fixtures/support/text-file.txt"), "text/plain") }
  let(:file_2) { fixture_file_upload(Rails.root.join("spec/fixtures/support/another-text-file.txt"), "text/plain") }
  let(:document_uploader) { support_case.document_uploader(files: [file_1, file_2]) }

  before do
    Current.agent = agent
    create(:support_email_template, title: "Contract handover email invitation", subject: "about energy", body: "Test body {{sub_category}} ")
  end

  def create_contract_recipients_and_upload_document
    support_case.contract_recipients.create!(first_name: "Momo", last_name: "Taro", email: "email@address")
    document_uploader.save_contract_handover_pack!
  end

  def share_handover_packs(support_case)
    create(:support_email, :inbox, ticket: support_case, outlook_conversation_id: "OCID1", subject: "Share handover pack", recipients: [{ "name" => "Test 1", "address" => "test1@email.com" }], unique_body: "Email 1", is_read: false)
  end

  specify "When add contract recipients and upload contract handover pack status are complete" do
    create_contract_recipients_and_upload_document

    support_case.update!(has_uploaded_contract_handovers: true)

    support_case.reload

    visit support_case_path(support_case, anchor: "tasklist")

    expect(find("#handover_contract-1-status")).to have_text("Complete")
    expect(find("#handover_contract-2-status")).to have_text("Complete")
    expect(find("#handover_contract-3-status")).to have_text("To do")
  end

  specify "When share handover pack is complete" do
    create_contract_recipients_and_upload_document

    support_case.update!(has_uploaded_contract_handovers: true, has_shared_handover_pack: true)

    support_case.reload

    visit support_case_path(support_case, anchor: "tasklist")

    expect(find("#handover_contract-3-status")).to have_text("Complete")
  end
end
