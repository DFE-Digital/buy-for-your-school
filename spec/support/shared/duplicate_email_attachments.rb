RSpec.shared_context "with duplicated email attachments" do
  let(:case_1) { create(:support_case) }
  let(:case_2) { create(:support_case) }

  let(:file_1) { fixture_file_upload(Rails.root.join("spec/fixtures/support/text-file.txt"), "text/plain") }
  let(:file_2) { fixture_file_upload(Rails.root.join("spec/fixtures/support/another-text-file.txt"), "text/plain") }
  # same file name, different checksum
  let(:file_3) { fixture_file_upload(Rails.root.join("spec/fixtures/text-file.txt"), "text/plain") }

  let!(:case_1_attachment_1) { create(:support_email_attachment, file: file_1, email: create(:support_email, :inbox, ticket: case_1)) }
  let!(:case_1_attachment_2) { create(:support_email_attachment, file: file_2, email: create(:support_email, :inbox, ticket: case_1)) }
  let!(:case_1_attachment_3) { create(:support_email_attachment, file: file_2, email: create(:support_email, :inbox, ticket: case_1)) }
  let!(:case_1_attachment_4) { create(:support_email_attachment, file: file_3, email: create(:support_email, :inbox, ticket: case_1)) }
  let!(:case_2_attachment_1) { create(:support_email_attachment, file: file_1, email: create(:support_email, :inbox, ticket: case_2)) }
  let!(:case_2_attachment_2) { create(:support_email_attachment, file: file_1, email: create(:support_email, :inbox, ticket: case_2)) }
  let!(:case_2_attachment_3) { create(:support_email_attachment, file: file_2, email: create(:support_email, :inbox, ticket: case_2)) }
end
