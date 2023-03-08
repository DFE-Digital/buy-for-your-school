describe "Agent can view email attachments in attachments tab" do
  include_context "with an agent"

  before { click_button "Agent Login" }

  let(:support_case) { create(:support_case) }
  let!(:attachment) { create(:support_email_attachment, file: Rack::Test::UploadedFile.new("spec/fixtures/files/text-file.txt", "text/plain")).tap { |ea| ea.email.update(case: support_case) } }

  it "displays them within the Attachments tab", js: true do
    visit support_case_path(support_case)

    within "#case-attachments tr", text: "text-file.txt" do
      expect(page).to have_link("text-file.txt", href: support_document_download_path(attachment, type: attachment.class))
    end
  end
end
