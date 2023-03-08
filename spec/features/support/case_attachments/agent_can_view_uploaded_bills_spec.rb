describe "Agent can view uploaded bills" do
  include_context "with an agent"

  before { click_button "Agent Login" }

  context "when there are bills on the case" do
    let(:support_case) { create(:support_case) }
    let!(:bill) { create(:energy_bill, support_case:, filename: "energy_bill_1.pdf", file: Rack::Test::UploadedFile.new("spec/fixtures/files/text-file.txt", "text/plain")) }

    it "displays them within the Files tab", js: true do
      visit support_case_path(support_case)

      within "#case-files tr", text: "energy_bill_1.pdf" do
        expect(page).to have_link("energy_bill_1.pdf", href: support_document_download_path(bill, type: bill.class))
      end
    end
  end
end
