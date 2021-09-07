RSpec.describe Support::Document, type: :model do
  let(:documentable) { nil }
  let(:document) { create(:support_document, documentable: documentable) }

  context "when document belongs to a case" do
    let!(:documentable) { create(:support_case) }

    it "is a case" do
      expect(document.documentable).to be_kind_of documentable.class
    end
  end

  context "when document belongs to a enquiry" do
    let!(:documentable) { create(:support_enquiry) }

    it "is an enquiry" do
      expect(document.documentable).to be_kind_of documentable.class
    end
  end
end
