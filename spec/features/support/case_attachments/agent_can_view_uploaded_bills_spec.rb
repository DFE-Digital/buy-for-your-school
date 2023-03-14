describe "Agent can view uploaded bills" do
  include_context "with an agent"

  before { click_button "Agent Login" }

  context "when there are bills on the case" do
    let(:support_case) { create(:support_case) }
    let(:bill) { create(:energy_bill, file: Rack::Test::UploadedFile.new("spec/fixtures/files/text-file.txt", "text/plain")) }
    let!(:case_attachment) { create(:support_case_attachment, case: support_case, custom_name: "energy_bill_1.pdf", attachable: bill) }

    it "displays them within the Files tab", js: true do
      visit support_case_path(support_case)

      within "#case-files tr", text: "energy_bill_1.pdf" do
        expect(page).to have_link("energy_bill_1.pdf", href: support_document_download_path(case_attachment, type: case_attachment.class))
      end
    end
  end
end
