RSpec.describe Support::Document, type: :model do
  subject(:document) { create(:support_document) }

  it { is_expected.to belong_to :case }

  describe ".for_rendering" do
    before do
      create(:support_document, document_body: nil)
      create(:support_document, document_body: nil)
      create(:support_document, document_body: "Has Content")
    end

    it "only returns documents with a body" do
      results = described_class.for_rendering

      expect(results.count).to be(1)
      expect(results.first.document_body).to eq("Has Content")
    end
  end
end
