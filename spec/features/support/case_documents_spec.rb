require "rails_helper"

describe "Case documents" do
  include_context "with an agent"

  let(:support_case) { create(:support_case, :with_documents) }
  let(:document) { support_case.documents.first }

  context "when a document has no body" do
    let(:bad_document) { create(:support_document, document_body: nil, case: support_case) }

    before do
      create(:support_interaction, :support_request, case: support_case, additional_data: { "message" => "Need help" })
    end

    it "does not show it" do
      visit support_case_path(support_case, anchor: "case-history")

      expect(page).to have_css("a[href='#{support_case_document_path(support_case, document)}']", visible: :all)
      expect(page).not_to have_css("a[href='#{support_case_document_path(support_case, bad_document)}']", visible: :all)
    end
  end

  it "renders the document body on the page" do
    visit support_case_document_path(support_case, document)

    within "article.specification" do
      expect(page).to have_content(document.document_body)
    end
  end
end
