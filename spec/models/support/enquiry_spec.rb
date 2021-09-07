RSpec.describe Support::Enquiry, type: :model do
  subject(:support_enquiry) { create(:support_enquiry) }

  context "with case" do
    let!(:support_case) { create(:support_case, enquiry: support_enquiry) }

    it "belongs to case" do
      expect(support_enquiry.case).not_to be_nil
      expect(support_enquiry.case.ref).to eql support_case.ref
    end
  end

  context "with documents" do
    let!(:document) { create(:support_document, documentable: support_enquiry) }

    it "has document returned in collection" do
      expect(support_enquiry.documents).not_to be_empty
      expect(support_enquiry.documents.first.document_body).to eql document.document_body
    end
  end
end
