require "rails_helper"

describe "Case documents" do
  include_context "with an agent"

  let(:support_case) { create(:support_case, :with_documents) }
  let(:document) { support_case.documents.first }

  context "when a document has no body" do
    let(:bad_document) { create(:support_document, document_body: nil, case: support_case) }

    it "does not show it" do
      expect { visit support_case_document_path(support_case, bad_document) }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  it "renders the document body on the page" do
    visit support_case_document_path(support_case, document)

    within "article.specification" do
      expect(page).to have_content(document.document_body)
    end
  end
end
