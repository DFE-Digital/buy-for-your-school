describe Support::Management::EmailTemplatesController, type: :controller do
  before { agent_is_signed_in(admin: true, roles: %w[procops_admin]) }

  describe "attachment_list" do
    let!(:email_template) { create(:support_email_template) }
    let!(:attachment_1) { create(:support_email_template_attachment, template: email_template, file: Rack::Test::UploadedFile.new(Rails.root.join("spec/fixtures/support/text-file.txt"), "text/plain")) }
    let!(:attachment_2) { create(:support_email_template_attachment, template: email_template, file: Rack::Test::UploadedFile.new(Rails.root.join("spec/fixtures/support/javascript-file.js"), "application/javascript")) }

    it "returns all attachments for given email template" do
      get :attachment_list, params: { id: email_template.id }
      expect(JSON.parse(response.body)).to eq(
        [
          {
            "file_id" => attachment_1.id,
            "name" => attachment_1.file_name,
            "url" => support_document_download_path(attachment_1, type: attachment_1.class),
            "type" => "template_attachment",
          },
          {
            "file_id" => attachment_2.id,
            "name" => attachment_2.file_name,
            "url" => support_document_download_path(attachment_2, type: attachment_2.class),
            "type" => "template_attachment",
          },
        ],
      )
    end
  end
end
